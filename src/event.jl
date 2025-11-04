
"""
    EventType

Type for built-in and custom events.
See [EventRegistry](@ref) for creating custom event types.

# Built-in event types

  - `OnCreateEntity`: Event emitted when a new entity is created.
  - `OnRemoveEntity`: Event emitted when an entity is removed from the [World](@ref).
  - `OnAddComponents`: Event emitted when components are added to an entity.
  - `OnRemoveComponents`: Event emitted when components are removed from an entity.
"""
struct EventType
    _id::UInt8

    EventType(id::UInt8) = new(id)
end

const OnCreateEntity::EventType = EventType(UInt8(1))
const OnRemoveEntity::EventType = EventType(UInt8(2))
const OnAddComponents::EventType = EventType(UInt8(3))
const OnRemoveComponents::EventType = EventType(UInt8(4))
const _custom_events::EventType = EventType(UInt8(5))

"""
    EventRegistry

Serves for creating custom event types.
"""
mutable struct EventRegistry
    _next_index::UInt8
end

"""
    EventRegistry()

Creates a new [EventRegistry](@ref).
"""
function EventRegistry()
    EventRegistry(_custom_events._id - 1)
end

"""
    new_event_type!(reg::EventRegistry)

Creates a new custom [EventType](@ref).
Custom event types are best stored in global constants.
"""
function new_event_type!(reg::EventRegistry)
    if reg._next_index == typemax(UInt8)
        error("reached maximum number of $(reg._next_index) event types")
    end
    reg._next_index += 1
    return EventType(reg._next_index)
end

mutable struct _ObserverID
    id::UInt32
end

"""
    Observer

Observer for reacting on built-in and custom events.

See [@observe!](@ref) for details.
See [EventType](@ref) for built-in, and [EventRegistry](@ref) for custom event types.
"""
struct Observer
    _id::_ObserverID
    _event::EventType
    _comps::_Mask
    _with::_Mask
    _without::_Mask
    _has_comps::Bool
    _has_with::Bool
    _has_without::Bool
    _fn::FunctionWrapper{Nothing,Tuple{Entity}}
end

mutable struct _EventManager
    const observers::Vector{Vector{Observer}}
    const union_comps::Vector{_Mask}
    const union_with::Vector{_Mask}
    const any_no_with::Vector{Bool}
    const any_no_comps::Vector{Bool}
    num_observers::Int
end

function _EventManager()
    len = typemax(UInt8)
    _EventManager(
        [Vector{Observer}() for _ in 1:len],
        [_Mask() for _ in 1:len],
        [_Mask() for _ in 1:len],
        fill(false, len),
        fill(false, len),
        0,
    )
end

function _has_observers(m::_EventManager, event::EventType)
    return m.num_observers > 0 && length(m.observers[event._id]) > 0
end

function _add_observer!(m::_EventManager, o::Observer)
    if o._id.id > 0
        error("observer is already registered")
    end
    m.num_observers += 1

    e = o._event._id
    push!(m.observers[e], o)
    o._id.id = UInt32(length(m.observers[e]))

    if o._has_with
        m.union_with[e] = _or(m.union_with[e], o._with)
    else
        m.any_no_with[e] = true
    end

    if o._event == OnCreateEntity || o._event == OnRemoveEntity
        return
    end

    if o._has_comps
        m.union_comps[e] = _or(m.union_comps[e], o._comps)
    else
        m.any_no_comps[e] = true
    end
end

function _remove_observer!(m::_EventManager, o::Observer)
    if o._id.id == 0
        error("observer is not registered")
    end
    m.num_observers -= 1

    e = o._event._id
    observers = m.observers[e]
    swapped = _swap_remove!(observers, o._id.id)
    if swapped
        observers[o._id.id]._id.id = o._id.id
    end
    o._id.id = 0

    # rebuild mask unions

    m.any_no_with[e] = false
    with_mask = _Mask()
    for o in m.observers[e]
        if !o._has_with
            m.any_no_with[e] = true
            break # skip, as the unions mask is irrelevant
        end
        with_mask = _or(with_mask, o._with)
    end
    m.union_with[e] = with_mask

    if o._event == OnCreateEntity || o._event == OnRemoveEntity
        return
    end

    m.any_no_comps[e] = false
    comps_mask = _Mask()
    for o in m.observers[e]
        if !o._has_comps
            m.any_no_comps[e] = true
            break # skip, as the unions mask is irrelevant
        end
        comps_mask = _or(comps_mask, o._comps)
    end
    m.union_comps[e] = comps_mask
end

function _fire_create_entity_if_has(m::_EventManager, entity::Entity, mask::_Mask)
    if !_has_observers(m, OnCreateEntity)
        return
    end
    _fire_create_or_remove_entity(m, entity, mask, OnCreateEntity, true)
    return nothing
end

function _fire_remove_entity(m::_EventManager, entity::Entity, mask::_Mask)
    _fire_create_or_remove_entity(m, entity, mask, OnRemoveEntity, true)
    return nothing
end

function _fire_create_or_remove_entity(
    m::_EventManager,
    entity::Entity,
    mask::_Mask,
    event::EventType,
    early_out::Bool,
)::Bool
    evt = event._id
    if early_out && !m.any_no_with[evt] && !_contains_any(m.union_with[evt], mask)
        return false
    end
    found = false
    for o in m.observers[evt]
        if o._has_with && !_contains_all(mask, o._with)
            continue
        end
        if o._has_without && _contains_any(mask, o._without)
            continue
        end
        o._fn(entity)
        found = true
    end
    return found
end

function _fire_create_entities_if_has(m::_EventManager, arch::_BatchArchetype)
    if !_has_observers(m, OnCreateEntity)
        return
    end
    _fire_create_entities(m, arch)
    return nothing
end

function _fire_create_entities(m::_EventManager, arch::_BatchArchetype)
    evt = OnCreateEntity._id
    mask = arch.archetype.mask
    if !m.any_no_with[evt] && !_contains_any(m.union_with[evt], mask)
        return
    end
    for o in m.observers[evt]
        if o._has_with && !_contains_all(mask, o._with)
            continue
        end
        if o._has_without && _contains_any(mask, o._without)
            continue
        end
        entities = arch.archetype.entities._data
        for i in arch.start_idx:arch.end_idx
            o._fn(entities[i])
        end
    end
end

function _fire_add_components_if_has(m::_EventManager, entity::Entity, old_mask::_Mask, new_mask::_Mask)
    if !_has_observers(m, OnAddComponents)
        return
    end
    _fire_add_components(m, entity, old_mask, new_mask, true)
    return nothing
end

function _fire_add_components(
    m::_EventManager,
    entity::Entity,
    old_mask::_Mask,
    new_mask::_Mask,
    early_out::Bool,
)::Bool
    evt = OnAddComponents._id
    if early_out
        if !m.any_no_comps[evt] &&
           (!_contains_any(m.union_comps[evt], new_mask) || _contains_all(old_mask, m.union_comps[evt]))
            return false
        end
        if !m.any_no_with[evt] && !_contains_any(m.union_with[evt], old_mask)
            return false
        end
    end
    found = false
    for o in m.observers[evt]
        if o._has_comps && (!_contains_all(new_mask, o._comps) || _contains_any(old_mask, o._comps))
            continue
        end
        if o._has_with && !_contains_all(old_mask, o._with)
            continue
        end
        if o._has_without && _contains_any(old_mask, o._without)
            continue
        end
        o._fn(entity)
        found = true
    end
    return found
end

function _fire_remove_components(
    m::_EventManager,
    entity::Entity,
    old_mask::_Mask,
    new_mask::_Mask,
    early_out::Bool,
)::Bool
    evt = OnRemoveComponents._id
    if early_out
        if !m.any_no_comps[evt] &&
           (!_contains_any(m.union_comps[evt], old_mask) || _contains_all(new_mask, m.union_comps[evt]))
            return false
        end
        if !m.any_no_with[evt] && !_contains_any(m.union_with[evt], old_mask)
            return false
        end
    end
    found = false
    for o in m.observers[evt]
        if o._has_comps && (!_contains_all(old_mask, o._comps) || _contains_any(new_mask, o._comps))
            continue
        end
        if o._has_with && !_contains_all(old_mask, o._with)
            continue
        end
        if o._has_without && _contains_any(old_mask, o._without)
            continue
        end
        o._fn(entity)
        found = true
    end
    return found
end

function _fire_custom_event(
    m::_EventManager,
    entity::Entity,
    event::EventType,
    mask::_Mask,
    entity_mask::_Mask,
)
    evt = event._id
    if !m.any_no_comps[evt] && !_contains_any(m.union_comps[evt], mask)
        return
    end
    if !m.any_no_with[evt] && !_contains_any(m.union_with[evt], entity_mask)
        return
    end
    for o in m.observers[evt]
        if o._has_comps && !_contains_all(mask, o._comps)
            continue
        end
        if o._has_with && !_contains_all(entity_mask, o._with)
            continue
        end
        if o._has_without && _contains_any(entity_mask, o._without)
            continue
        end
        o._fn(entity)
    end
end
