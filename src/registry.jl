
mutable struct _ComponentRegistry
    counter::Int
    const components::Dict{DataType,Int}
    const types::Vector{DataType}
end

function _ComponentRegistry()
    _ComponentRegistry(0x01, Dict{DataType,Int}(), Vector{DataType}())
end

@inline function _get_id!(registry::_ComponentRegistry, ::Type{C})::Int where C
    if haskey(registry.components, C)
        return registry.components[C]
    end
    throw(ArgumentError(lazy"component type $C is not registered"))
end

function _register_component!(registry::_ComponentRegistry, ::Type{C})::Int where C
    if haskey(registry.components, C)
        throw(ArgumentError(lazy"duplicate component type $C during world creation"))
    end
    id = registry.counter
    registry.components[C] = id
    push!(registry.types, C)
    registry.counter += 1
    return id
end
