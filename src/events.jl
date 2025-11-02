
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
