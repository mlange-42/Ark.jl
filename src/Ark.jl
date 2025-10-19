module Ark

include("registry.jl")
include("storage.jl")

mutable struct World
    registry::_ComponentRegistry
    storages::Vector{Any}  # List of ComponentStorage{C}, stored as `Any`
    archetypes::Vector{_Archetype}
end

function World()
    World(_ComponentRegistry(), Vector{Any}(), Vector{_Archetype}())
end

function _component_id!(world::World, ::Type{C}) where C
    id = _component_id!(world.registry, C)
    if id >= length(world.storages)
        push!(world.storages, _ComponentStorage{C}())
    end
    return id
end

end
