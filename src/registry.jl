

mutable struct ComponentRegistry
    counter::UInt8
    components::Dict{DataType, UInt8}
end

function ComponentRegistry()
    ComponentRegistry(0x00, Dict{DataType, UInt8}())
end

function component_id!(registry::ComponentRegistry, ::Type{C}) where C
    if haskey(registry.components, C)
        return registry.components[C]
    elseif registry.counter == typemax(UInt8)
        error("ComponentRegistry exhausted UInt8 range")
    else
        id = registry.counter
        registry.components[C] = id
        registry.counter += 0x01
        return id
    end
end
