
struct EventType
    _id::UInt8

    EventType(id::UInt8) = new(id)
end

const OnCreateEntity::EventType = EventType(UInt8(1))
const OnRemoveEntity::EventType = EventType(UInt8(2))
const OnAddComponents::EventType = EventType(UInt8(3))
const OnRemoveComponents::EventType = EventType(UInt8(4))

mutable struct EventRegistry
    _next_index::UInt8
end

function EventRegistry()
    EventRegistry(OnRemoveEntity._id)
end

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

struct Observer
    _id::_ObserverID
    _event::EventType
    _comps::_Mask
    _with::_Mask
    _without::_Mask
    _has_excluded::Bool
    _fn::FunctionWrapper{Nothing,Tuple{Entity}}
end

struct _EventManager
    observers::Vector{Vector{Observer}}
    union_comps::Vector{_Mask}
    union_with::Vector{_Mask}
    any_no_with::Vector{Bool}
    any_no_comps::Vector{Bool}
end

function _EventManager()
    len = typemax(UInt8)
    _EventManager(
        fill(Vector{Observer}(), len),
        fill(_Mask(), len),
        fill(_Mask(), len),
        fill(false, len),
        fill(false, len),
    )
end

function _has_observers(m::_EventManager, event::EventType)
    return length(m.observers[event._id]) > 0
end

function _add_observer!(m::_EventManager, o::Observer)
    if o._id.id > 0
        error("observer is already registered")
    end
    push!(m.observers[o._event._id], o)
    o._id.id = UInt32(length(m.observers[o._event._id]))
end

function _remove_observer!(m::_EventManager, o::Observer)
    if o._id.id == 0
        error("observer is not registered")
    end
    observers = m.observers[o._event._id]
    swapped = _swap_remove!(observers, o._id.id)
    if swapped
        observers[o._id.id]._id.id = o._id.id
    end
    o._id.id = 0
end
