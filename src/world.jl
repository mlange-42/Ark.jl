
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
        [_Archetype()],
        _ComponentRegistry(),
    )
end

function _component_id!(world::World, ::Type{C}) where C
    id = _component_id!(world._registry, C)
    if id >= length(world._storages)
        push!(world._storages, _ComponentStorage{C}(length(world._archetypes)))
    end
    return id
end

function _get_storage(world::World, id::UInt8, ::Type{C})::_ComponentStorage{C} where C
    storage = world._storages[id]::_ComponentStorage{C}
    return storage
end

function _get_storage(world::World, ::Type{C})::_ComponentStorage{C} where C
    id = _component_id!(world, C)
    return _get_storage(world, id, C)
end

function _create_archetype!(world::World, components::UInt8...)
    arch = _Archetype(components...)
    push!(world._archetypes, arch)
    index = length(world._archetypes)
    for (i, tp) in enumerate(world._registry.types)
        storage = _get_storage(world, UInt8(i), tp)
        push!(storage.data, nothing)
    end
    for comp in components
        tp = world._registry.types[comp]
        storage = _get_storage(world, comp, tp)
        storage.data[index] = Vector{tp}()
    end
end
