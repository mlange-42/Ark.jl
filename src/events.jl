include("function.jl")

using .FunctionWrappers
import .FunctionWrappers: FunctionWrapper

const OnCreateEntity = :OnCreateEntity
const OnRemoveEntity = :OnRemoveEntity

struct _EventManager
    registry::Dict{Symbol,Int}
end

function _EventManager()
    registry = Dict{Symbol,Int}(
        :OnCreateEntity => 1,
        :OnRemoveEntity => 2,
    )
    _EventManager(registry)
end

function _register_event!(m::_EventManager, sym::Symbol)
    get!(m.registry, sym) do
        length(m.registry) + 1
    end
end

@inline function _event_index(m::_EventManager, ::Val{sym}) where sym
    return m.registry[sym]
end

struct Observer
    id::UInt8
    fn::FunctionWrapper{Int,Tuple{Int}}
end

function Observer(fn::Function)
    Observer(UInt8(0), FunctionWrapper{Int,Tuple{Int}}(fn))
end
