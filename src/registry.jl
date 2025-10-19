

mutable struct ComponentRegistry
    counter::UInt8
    components::Dict{DataType, UInt8}
end

function ComponentRegistry()
    ComponentRegistry(0x00, Dict{DataType, UInt8}())
end

function component_id!(registry::ComponentRegistry, ::Type{T}) where T
    if haskey(registry.components, T)
        return registry.components[T]
    elseif registry.counter == typemax(UInt8)
        error("ComponentRegistry exhausted UInt8 range")
    else
        id = registry.counter
        registry.components[T] = id
        registry.counter += 0x01
        return id
    end
end
