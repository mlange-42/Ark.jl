
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

struct Observer
    _event::EventType
    _comps::_Mask
    _with::_Mask
    _without::_Mask
    _exclusive::Bool
    _fn::FunctionWrapper{Nothing,Tuple{Entity}}
end

struct _EventManager
    observers::Vector{Vector{Observer}}
end

function _add_observer(m::_EventManager, o::Observer)
    if length(m.observers) < o._event
        resize!(m.observers, o._event)
        m.observers[o._event] = Vector{Observer}()
    end
    push!(m.observers[o._event], o)
end
