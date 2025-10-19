module Ark

include("entity.jl")
include("registry.jl")
include("storage.jl")

mutable struct World
    _entities::Vector{_EntityIndex}
    _storages::Vector{Any}  # List of ComponentStorage{C}, stored as `Any`
    _archetypes::Vector{_Archetype}
    _registry::_ComponentRegistry
end

function World()
    World(
        Vector{_EntityIndex}(),
        Vector{Any}(),
        Vector{_Archetype}(),
        _ComponentRegistry(),
    )
end

function _component_id!(world::World, ::Type{C}) where C
    id = _component_id!(world._registry, C)
    if id >= length(world._storages)
        push!(world._storages, _ComponentStorage{C}())
    end
    return id
end

function _get_storage(world::World, id::UInt8, ::Type{C})::_ComponentStorage{C} where C
    storage = world._storages[id+1]::_ComponentStorage{C}
    return storage
end

function _get_storage(world::World, ::Type{C})::_ComponentStorage{C} where C
    id = _component_id!(world, C)
    return _get_storage(world, id, C)
end

end
