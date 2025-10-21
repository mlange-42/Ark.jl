
mutable struct _ComponentRegistry
    counter::UInt8
    components::Dict{DataType,UInt8}
    types::Vector{DataType}
end

function _ComponentRegistry()
    _ComponentRegistry(0x01, Dict{DataType,UInt8}(), Vector{DataType}())
end

@inline function _component_id!(registry::_ComponentRegistry, ::Type{C})::UInt8 where C
    if haskey(registry.components, C)
        return registry.components[C]
    elseif registry.counter == typemax(UInt8)
        error("ComponentRegistry exhausted UInt8 range")
    end
    _register_component!(registry, C)
end

@inline function _get_id!(registry::_ComponentRegistry, ::Type{C})::UInt8 where C
    if haskey(registry.components, C)
        return registry.components[C]
    end
    error("component is not registered")
end

function _register_component!(registry::_ComponentRegistry, ::Type{C})::UInt8 where C
    id = registry.counter
    registry.components[C] = id
    push!(registry.types, C)
    registry.counter += 0x01
    return id
end
