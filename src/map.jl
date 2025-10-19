"""
    Map2{A,B}

A component mapper for 2 components.
"""
struct Map2{A,B}
    _world::World
    _ids::Tuple{UInt8,UInt8}
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
end

"""
    Map2{A,B}(world::World)

Creates a component mapper for 2 components.
"""
function Map2{A,B}(world::World) where {A,B}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
    )
    return Map2{A,B}(
        world,
        ids,
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
    )
end

"""
    new_entity!(map::Map2{A,B}, a::A, b::B)::Entity

Creates a new [`Entity`](@ref) with two components.
"""
function new_entity!(map::Map2{A,B}, a::A, b::B)::Entity where {A,B}
    archetype = _find_or_create_archetype!(map._world, map._world._archetypes[1].mask, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    map._storage_b.data[archetype][index] = b
    return entity
end

"""
    get_components(map::Map2{A,B}, entity::Entity)::Tuple{A,B}

Get two components of an [`Entity`](@ref).
"""
@inline function get_components(map::Map2{A,B}, entity::Entity)::Tuple{A,B} where {A,B}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # of for returning nothing?
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    b = map._storage_b.data[index.archetype][index.row]
    return a, b
end

"""
    set_components!(map::Map2{A,B}, entity::Entity, a::A, b::B)

Set two components of an [`Entity`](@ref).
"""
function set_components!(map::Map2{A,B}, entity::Entity, a::A, b::B) where {A,B}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error?
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = a
    map._storage_b.data[index.archetype][index.row] = b
end

"""
    has_components!(map::Map2{A,B}, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
function has_components(map::Map2{A,B}, entity::Entity) where {A,B}
    if !is_alive(map._world, entity)
        error("can't check components of a dead entity")
    end
    index = map._world._entities[entity._id]
    if map._storage_a.data[index.archetype] == nothing
        return false
    end
    if map._storage_b.data[index.archetype] == nothing
        return false
    end
    return true
end

"""
    add_components!(map::Map2{A,B}, a::A, b::B)::Entity

Adds two components to an [`Entity`](@ref).
"""
function add_components!(map::Map2{A,B}, entity::Entity, a::A, b::B) where {A,B}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    map._storage_a.data[archetype][row] = a
    map._storage_b.data[archetype][row] = b
end

"""
    remove_components!(map::Map2{A,B}, entity::Entity)

Removes two components from an [`Entity`](@ref).
"""
function remove_components!(map::Map2{A,B}, entity::Entity) where {A,B}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end
