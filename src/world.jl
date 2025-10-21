
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
    _lock::_Lock
    _graph::_Graph
end

"""
    World()

Creates a new, empty [`World`](@ref).
"""
function World()
    graph = _Graph()
    World(
        [_EntityIndex(typemax(UInt32), 0)],
        Vector{Any}(),
        [_Archetype(graph.nodes[1])],
        _ComponentRegistry(),
        _EntityPool(UInt32(1024)),
        _Lock(),
        graph,
    )
end

@inline function _component_id!(world::World, ::Type{C})::UInt8 where C
    id = _component_id!(world._registry, C)
    if id > length(world._storages)
        push!(world._storages, _ComponentStorage{C}(length(world._archetypes)))
    end
    return id
end

function _get_storage(world::World, id::UInt8, ::Type{C})::_ComponentStorage{C} where C
    return _cast_to(_ComponentStorage{C}, world._storages[id])
end

function _get_storage(world::World, ::Type{C})::_ComponentStorage{C} where C
    id = _component_id!(world, C)
    return _get_storage(world, id, C)
end

function _find_or_create_archetype!(world::World, entity::Entity, add::Tuple{Vararg{UInt8}}, remove::Tuple{Vararg{UInt8}})::UInt32
    index = world._entities[entity._id]
    return _find_or_create_archetype!(world, world._archetypes[index.archetype].node, add, remove)
end

function _find_or_create_archetype!(world::World, start::_GraphNode, add::Tuple{Vararg{UInt8}}, remove::Tuple{Vararg{UInt8}})::UInt32
    node = _find_node(world._graph, start, add, remove)

    archetype = (node.archetype == typemax(UInt32)) ?
                _create_archetype!(world, node) :
                node.archetype

    return archetype
end

function _create_archetype!(world::World, node::_GraphNode)::UInt32
    components = _active_bit_indices(node.mask)
    arch = _Archetype(node, components...)
    push!(world._archetypes, arch)
    node.archetype = length(world._archetypes)

    index = length(world._archetypes)
    for (i, tp) in enumerate(world._registry.types)
        storage = _get_storage(world, UInt8(i), tp)
        push!(storage.data, nothing)
    end
    for comp in components
        tp = world._registry.types[comp]
        storage = _get_storage(world, comp, tp)
        storage.data[index] = _new_column(tp)
    end
    return index
end

function _create_entity!(world::World, archetype_index::UInt32)::Tuple{Entity,UInt32}
    _check_locked(world)

    entity = _get_entity(world._entity_pool)
    archetype = world._archetypes[archetype_index]

    index = _add_entity!(archetype, entity)
    for comp in archetype.components
        tp = world._registry.types[comp]
        storage = _get_storage(world, comp, tp)
        vec = storage.data[archetype_index]
        resize!(vec._data, index)
    end

    if entity._id > length(world._entities)
        push!(world._entities, _EntityIndex(archetype_index, index))
    else
        world._entities[entity._id] = _EntityIndex(archetype_index, index)
    end
    return entity, index
end

function _move_entity!(world::World, entity::Entity, archetype_index::UInt32)::UInt32
    _check_locked(world)

    index = world._entities[entity._id]
    old_archetype = world._archetypes[index.archetype]
    new_archetype = world._archetypes[archetype_index]

    new_row = _add_entity!(new_archetype, entity)
    swapped = _swap_remove!(old_archetype.entities._data, index.row)
    for comp in old_archetype.components
        if !_get_bit(new_archetype.mask, comp)
            continue
        end
        tp = world._registry.types[comp]
        storage = _get_storage(world, comp, tp)
        old_vec = storage.data[index.archetype]
        new_vec = storage.data[archetype_index]
        push!(new_vec._data, old_vec[index.row])
        _swap_remove!(old_vec._data, index.row)
    end
    for comp in new_archetype.components
        tp = world._registry.types[comp]
        storage = _get_storage(world, comp, tp)
        new_vec = storage.data[archetype_index]
        if length(new_vec) == new_row
            continue
        end
        resize!(new_vec._data, new_row)
    end

    if swapped
        swap_entity = old_archetype.entities[index.row]
        world._entities[swap_entity._id] = index
    end

    world._entities[entity._id] = _EntityIndex(archetype_index, new_row)
    return new_row
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
function is_alive(world::World, entity::Entity)::Bool
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
    _check_locked(world)

    index = world._entities[entity._id]
    archetype = world._archetypes[index.archetype]

    swapped = _swap_remove!(archetype.entities._data, index.row)
    for comp in archetype.components
        tp = world._registry.types[comp]
        storage = _get_storage(world, comp, tp)
        vec = storage.data[index.archetype]
        _swap_remove!(vec._data, index.row)
    end

    if swapped
        swap_entity = archetype.entities[index.row]
        world._entities[swap_entity._id] = index
    end

    _recycle(world._entity_pool, entity)
end

function is_locked(world::World)::Bool
    return _is_locked(world._lock)
end

function _check_locked(world::World)
    if _is_locked(world._lock)
        error("cannot modify a locked world: collect entities into a vector and apply changes after query iteration has completed")
    end
end
