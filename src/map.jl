

struct Map{CS<:Tuple, N}
    _world::World
    _ids::NTuple{N, UInt8}
    _storace::CS
end

function Map(world::World, comps::Tuple)
    ids = _component_id!.(world, comps)
    return Map(world, ids, _get_storage.(world, ids, comps))
end

function new_entity!(map::Map, comps::Tuple)
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].node, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    return entity
end

function get_components(map::Map, entity::Entity)
    return map[entity]
end

@inline function Base.getindex(map::Map1{A}, entity::Entity)::Tuple{A} where {A}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    return a
end

"""
    set_components!(map::Map1{ A }, entity::Entity, a::A)

Set 1 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
map[entity] = (Position(0, 0), Velocity(1, 1))
```
"""
function set_components!(map::Map1{A}, entity::Entity, a::A) where {A}
    map[entity] = (a)
end

@inline function Base.setindex!(map::Map1{A}, value::Tuple{A}, entity::Entity) where {A}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = value[1]
end

"""
    has_components!(map::Map1{ A }, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
function has_components(map::Map1{A}, entity::Entity) where {A}
    if !is_alive(map._world, entity)
        error("can't check components of a dead entity")
    end
    index = map._world._entities[entity._id]
    if map._storage_a.data[index.archetype] == nothing
        return false
    end
    return true
end

"""
    add_components!(map::Map1{ A }, a::A)::Entity

Adds 1 components to an [`Entity`](@ref).
"""
function add_components!(map::Map1{A}, entity::Entity, a::A) where {A}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    map._storage_a.data[archetype][row] = a
end

"""
    remove_components!(map::Map1{ A }, entity::Entity)

Removes 1 components from an [`Entity`](@ref).
"""
function remove_components!(map::Map1{A}, entity::Entity) where {A}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

@inline function Base.getindex(map::Map2{A,B}, entity::Entity)::Tuple{A,B} where {A,B}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    b = map._storage_b.data[index.archetype][index.row]
    return a, b
end

"""
    set_components!(map::Map2{ A,B }, entity::Entity, a::A, b::B)

Set 2 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
map[entity] = (Position(0, 0), Velocity(1, 1))
```
"""
function set_components!(map::Map2{A,B}, entity::Entity, a::A, b::B) where {A,B}
    map[entity] = (a, b)
end

@inline function Base.setindex!(
    map::Map2{A,B},
    value::Tuple{A,B},
    entity::Entity,
) where {A,B}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = value[1]
    map._storage_b.data[index.archetype][index.row] = value[2]
end
