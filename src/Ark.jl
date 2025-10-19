module Ark

include("registry.jl")
include("storage.jl")

mutable struct World
    registry::ComponentRegistry
    storages::Vector{Any}  # List of ComponentStorage{C}, stored as `Any`
    archetypes::Vector{Archetype}
end

function World()
    World(ComponentRegistry(), Vector{Any}(), Vector{Archetype}())
end

function component_id!(world::World, ::Type{C}) where C
    id = component_id!(world.registry, C)
    if id >= length(world.storages)
        push!(world.storages, ComponentStorage{C}())
    end
    return id
end

end
