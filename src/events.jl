include("function.jl")

using .FunctionWrappers
import .FunctionWrappers: FunctionWrapper

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

struct _EventManager
end

struct Observer
    _event::EventType
    _fn::FunctionWrapper{Nothing,Tuple{Entity}}
end

function Observer(fn::Function, event::EventType)
    Observer(event, FunctionWrapper{Nothing,Tuple{Entity}}(fn))
end
