
struct EventType
    _id::UInt8

    EventType(id::UInt8) = new(id)
end

const OnCreateEntity::EventType = EventType(UInt8(1))
const OnRemoveEntity::EventType = EventType(UInt8(2))

mutable struct EventRegistry
    _next_index::UInt8
end

function EventRegistry()
    EventRegistry(OnRemoveEntity._id)
end

function new_event_type!(reg::EventRegistry)
    reg._next_index += 1
    return EventType(reg._next_index)
end

mutable struct _ObserverID
    id::UInt32
end

struct Observer
    _id::_ObserverID
    _world::_AbstractWorld
    _event::EventType
    _comps::_Mask
    _with::_Mask
    _without::_Mask
    _has_excluded::Bool
    _fn::FunctionWrapper{Nothing,Tuple{Entity}}
end

struct _EventManager
    observers::Vector{Vector{Observer}}
end

function _EventManager()
    _EventManager(Vector{Vector{Observer}}())
end

function _add_observer!(m::_EventManager, o::Observer)
    if o._id.id > 0
        error("observer is already registered")
    end
    event = o._event._id
    old_length = length(m.observers)
    if old_length < event
        resize!(m.observers, event)
        for i in (old_length+1):event
            m.observers[i] = Vector{Observer}()
        end
    end
    push!(m.observers[event], o)
    o._id.id = UInt32(length(m.observers[event]))
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
