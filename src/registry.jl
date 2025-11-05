
mutable struct _ComponentRegistry
    counter::UInt8
    const components::Dict{DataType,UInt8}
    const types::Vector{DataType}
end

function _ComponentRegistry()
    _ComponentRegistry(0x01, Dict{DataType,UInt8}(), Vector{DataType}())
end

@inline function _get_id!(registry::_ComponentRegistry, ::Type{C})::UInt8 where C
    if haskey(registry.components, C)
        return registry.components[C]
    end
    throw(ArgumentError(lazy"component type $C is not registered"))
end

function _register_component!(registry::_ComponentRegistry, ::Type{C})::UInt8 where C
    if haskey(registry.components, C)
        throw(ArgumentError(lazy"duplicate component type $C during world creation"))
    end
    id = registry.counter
    registry.components[C] = id
    push!(registry.types, C)
    registry.counter += 0x01
    return id
end
