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

function _get_storage(world::World, id::UInt8, ::Type{C})::_ComponentStorage{C} where C
    storage = world.storages[id+1]::_ComponentStorage{C}
    return storage
end

function _get_storage(world::World, ::Type{C})::_ComponentStorage{C} where C
    id = _component_id!(world, C)
    return _get_storage(world, id, C)
end

end
