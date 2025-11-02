
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
    _has_excluded::Bool
    _fn::FunctionWrapper{Nothing,Tuple{Entity}}
end

struct _EventManager
    observers::Vector{Vector{Observer}}
end

function _add_observer(m::_EventManager, o::Observer)
    old_length = length(m.observers)
    if old_length < o._event
        resize!(m.observers, o._event)
        for i in (old_length + 1) .. o._event
            m.observers[i] = Vector{Observer}()
        end
    end
    push!(m.observers[o._event], o)
end
