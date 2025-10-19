
"""
    const zero_entity::Entity

The reserved zero [`Entity`](@ref) value.
"""
const zero_entity::Entity = _new_entity(1, 0)

"""
    World

The World is the central ECS storage.
"""
mutable struct World
    _entities::Vector{_EntityIndex}
    _storages::Vector{Any}  # List of ComponentStorage{C}, stored as `Any`
    _archetypes::Vector{_Archetype}
    _registry::_ComponentRegistry
    _entity_pool::_EntityPool
end

"""
    World()

Creates a new, empty [`World`](@ref).
"""
function World()
    World(
        [_EntityIndex(typemax(UInt32), 0)],
        Vector{Any}(),
        [_Archetype()],
        _ComponentRegistry(),
        _EntityPool(UInt32(1024)),
    )
end

@inline function _component_id!(world::World, ::Type{C}) where C
    id = _component_id!(world._registry, C)
    if id >= length(world._storages)
        push!(world._storages, _ComponentStorage{C}(length(world._archetypes)))
    end
    return id
end

@inline function _get_storage(world::World, id::UInt8, ::Type{C})::_ComponentStorage{C} where C
    return _cast_to(_ComponentStorage{C}, world._storages[id])
end

@inline function _get_storage(world::World, ::Type{C})::_ComponentStorage{C} where C
    id = _component_id!(world, C)
    return _get_storage(world, id, C)
end

function _find_or_create_archetype!(world::World, components::UInt8...)::UInt32
    # TODO: implement archetype graph for faster lookup.
    mask = _Mask(components...)
    for (i, arch) in enumerate(world._archetypes)
        if arch.mask == mask
            return i
        end
    end
    return _create_archetype!(world, mask, components...)
end

function _create_archetype!(world::World, mask::_Mask, components::UInt8...)::UInt32
    arch = _Archetype(mask, components...)
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
    return index
end

function _create_entity!(world::World, archetype_index::UInt32)::Tuple{Entity,UInt32}
    entity = _get_entity(world._entity_pool)
    archetype = world._archetypes[archetype_index]

    index = _add_entity!(archetype, entity)
    for comp in archetype.components
        tp = world._registry.types[comp]
        storage = _get_storage(world, comp, tp)
        vec = storage.data[archetype_index]
        resize!(vec, length(vec) + 1)
    end

    if entity._id > length(world._entities)
        push!(world._entities, _EntityIndex(archetype_index, index))
    else
        world._entities[entity._id] = _EntityIndex(archetype_index, index)
    end
    return entity, index
end

"""
    new_entity!(world::World)::Entity

Creates a new [`Entity`](@ref) without any components.
"""
function new_entity!(world::World)::Entity
    entity, _ = _create_entity!(world, UInt32(1))
    return entity
end

"""
    is_alive(world::World, entity::Entity)::Bool

Returns whether an [`Entity`](@ref) is alive.
"""
@inline function is_alive(world::World, entity::Entity)::Bool
    return _is_alive(world._entity_pool, entity)
end

"""
    remove_entity!(world::World, entity::Entity)

Removes an [`Entity`](@ref) from the [`World`](@ref).
"""
function remove_entity!(world::World, entity::Entity)
    if !is_alive(world, entity)
        error("can't remove a dead entity")
    end
    index = world._entities[entity._id]
    archetype = world._archetypes[index.archetype]

    swapped = _swap_remove!(archetype.entities, index.row)
    for comp in world._archetypes[index.archetype].components
        tp = world._registry.types[comp]
        storage = _get_storage(world, comp, tp)
        vec = storage.data[index.archetype]
        _swap_remove!(vec, index.row)
    end

    if swapped
        swap_entity = archetype.entities[index.row]
        world._entities[swap_entity._id] = index
    end

    _recycle(world._entity_pool, entity)
end
