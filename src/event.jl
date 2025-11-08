
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
        throw(InvalidStateException("reached maximum number of $(reg._next_index) event types", :events_exhausted))
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
struct Observer{K}
    _id::_ObserverID
    _event::EventType
    _comps::_Mask{K}
    _with::_Mask{K}
    _without::_Mask{K}
    _has_comps::Bool
    _has_with::Bool
    _has_without::Bool
    _fn::FunctionWrapper{Nothing,Tuple{Entity}}
end

mutable struct _EventManager{K}
    const observers::Vector{Vector{Observer{K}}}
    const comps::Vector{Tuple{_Mask{K},Bool}}
    const with::Vector{Tuple{_Mask{K},Bool}}
    num_observers::Int
end

function _EventManager{K}() where K
    len = typemax(UInt8)
    _EventManager{K}(
        [Vector{Observer{K}}() for _ in 1:len],
        [(_Mask{K}(), false) for _ in 1:len],
        [(_Mask{K}(), false) for _ in 1:len],
        0,
    )
end

@inline function _has_observers(m::_EventManager, event::EventType)
    return m.num_observers > 0 && length(m.observers[event._id]) > 0
end

function _add_observer!(m::_EventManager, o::Observer)
    if o._id.id > 0
        throw(InvalidStateException("observer is already registered", :observer_already_registered))
    end
    m.num_observers += 1

    e = o._event._id
    push!(m.observers[e], o)
    o._id.id = UInt32(length(m.observers[e]))

    with, any_no_with = m.with[e]
    if o._has_with
        with = _or(with, o._with)
    else
        any_no_with = true
    end
    m.with[e] = (with, any_no_with)

    if o._event == OnCreateEntity || o._event == OnRemoveEntity
        return
    end

    comps, any_no_comps = m.comps[e]
    if o._has_comps
        comps = _or(comps, o._comps)
    else
        any_no_comps = true
    end
    m.comps[e] = (comps, any_no_comps)
end

function _remove_observer!(m::_EventManager{K}, o::Observer{K}) where K
    if o._id.id == 0
        throw(InvalidStateException("observer is not registered", :observer_not_registered))
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

    with_mask = _Mask{K}()
    any_no_with = false
    for o in m.observers[e]
        if !o._has_with
            any_no_with = true
            break # skip, as the unions mask is irrelevant
        end
        with_mask = _or(with_mask, o._with)
    end
    m.with[e] = (with_mask, any_no_with)

    if o._event == OnCreateEntity || o._event == OnRemoveEntity
        return
    end

    comps_mask = _Mask{K}()
    any_no_comps = false
    for o in m.observers[e]
        if !o._has_comps
            any_no_comps = true
            break # skip, as the unions mask is irrelevant
        end
        comps_mask = _or(comps_mask, o._comps)
    end
    m.comps[e] = (comps_mask, any_no_comps)
end

function _fire_create_entity(m::_EventManager, entity::Entity, mask::_Mask)
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
    observers = m.observers[evt]
    with, any_no_with = m.with[evt]
    if early_out && length(observers) > 1 && !any_no_with && !_contains_any(with, mask)
        return false
    end
    found = false
    for o in observers
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

function _fire_create_entities(m::_EventManager, arch::_BatchArchetype)
    evt = OnCreateEntity._id
    observers = m.observers[evt]
    mask = arch.archetype.mask
    with, any_no_with = m.with[evt]
    if length(observers) > 1 && !any_no_with && !_contains_any(with, mask)
        return
    end
    for o in observers
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

function _fire_add_components(
    m::_EventManager,
    entity::Entity,
    old_mask::_Mask,
    new_mask::_Mask,
    early_out::Bool,
)::Bool
    evt = OnAddComponents._id
    observers = m.observers[evt]
    if early_out && length(observers) > 1
        comps, any_no_comps = m.comps[evt]
        if !any_no_comps &&
           (!_contains_any(comps, new_mask) || _contains_all(old_mask, comps))
            return false
        end
        with, any_no_with = m.with[evt]
        if !any_no_with && !_contains_any(with, old_mask)
            return false
        end
    end
    found = false
    for o in observers
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
    observers = m.observers[evt]
    if early_out && length(observers) > 1
        comps, any_no_comps = m.comps[evt]
        if !any_no_comps &&
           (!_contains_any(comps, old_mask) || _contains_all(new_mask, comps))
            return false
        end
        with, any_no_with = m.with[evt]
        if !any_no_with && !_contains_any(with, old_mask)
            return false
        end
    end
    found = false
    for o in observers
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
    observers = m.observers[evt]
    if length(observers) > 1
        comps, any_no_comps = m.comps[evt]
        if !any_no_comps && !_contains_any(comps, mask)
            return
        end
        with, any_no_with = m.with[evt]
        if !any_no_with && !_contains_any(with, entity_mask)
            return
        end
    end
    for o in observers
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
