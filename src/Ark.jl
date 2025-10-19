module Ark

include("registry.jl")
include("storage.jl")

struct World
    registry::ComponentRegistry
    storages::Vector{Any}  # List of ComponentStorage{C}, stored as `Any`
    archetypes::Vector{Archetype}
end

function World()
    World(ComponentRegistry(), Vector{Any}(), Vector{Archetype}())
end

end
