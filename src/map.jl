
"""
    Map{CS, N}

A component mapper for N components.
"""
struct Map{CS<:Tuple, N}
    _world::World
    _ids::NTuple{N, UInt8}
    _storage::CS
end

# TODO: this could also be generated
"""
    Map(world::World, CompsTypes)

Creates a component mapper.
"""
function Map(world::World, CompsTypes::Tuple)
    ids = Tuple(_component_id!(world, C) for C in CompsTypes)
    return Map(world, ids, Tuple(_get_storage(world, id, C) for (id, C) in zip(ids,CompsTypes)))
end

"""
    new_entity!(map::Map, comps::Tuple)::Entity

Creates a new [`Entity`](@ref) with `length(comps)` components.
"""
function new_entity!(map::Map, comps::Tuple)
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].node, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    _set_entity_values!(map, archetype, index, comps)
    return entity
end

"""
    get_components(map::Map, entity::Entity)

Get components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
pos, vel = map[entity]
```
"""
function get_components(map::Map, entity::Entity)
    return map[entity]
end

@inline function Base.getindex(map::Map, entity::Entity)
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    return _get_mapped_components(map, index)
end

"""
    set_components!(map::Map, entity::Entity, comps::Tuple)

Set components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
map[entity] = (Position(0, 0), Velocity(1, 1))
```
"""
function set_components!(map::Map, entity::Entity, comps)
    map[entity] = comps
end

@inline function Base.setindex!(map::Map, value, entity::Entity)
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    _set_mapped_components!(map, index, value)
end

"""
    has_components(map::Map, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
function has_components(map::Map, entity::Entity)
    if !is_alive(map._world, entity)
        error("can't check components of a dead entity")
    end
    index = map._world._entities[entity._id]
    return _has_entity_components(map, index)
end

"""
    add_components!(map::Map{CS,1}, entity::Entity, value)::Entity

Adds 1 components to an [`Entity`](@ref).
"""
function add_components!(map::Map, entity::Entity, value)
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    _set_entity_values!(map, archetype, row, value)
end

"""
    remove_components!(map::Map{CS,1}, entity::Entity)

Removes 1 components from an [`Entity`](@ref).
"""
function remove_components!(map::Map, entity::Entity)
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

@generated function _get_mapped_components(map::Map{CS}, index) where {CS <: Tuple}
    N = length(CS.parameters)
    expressions = [:(map._storage[$i].data[index.archetype][index.row]) for i in 1:N]
    return Expr(:tuple, expressions...)
end

@generated function _set_mapped_components!(map::Map{CS}, index, comps) where {CS <: Tuple}
    N = length(CS.parameters)
    expressions = [:(map._storage[$i].data[index.archetype][index.row] = comps[$i]) for i in 1:N]
    return quote $(expressions...) end
end

@generated function _set_entity_values!(map::Map{CS}, archetype, index, comps) where {CS <: Tuple}
    N = length(CS.parameters)
    expressions = [:(map._storage[$i].data[archetype][index] = comps[$i]) for i in 1:N]
    return quote $(expressions...) end
end

@generated function _has_entity_components(map::Map{CS}, index) where {CS <: Tuple}
    N = length(CS.parameters)
    expressions = [:(if map._storage[$i].data[index.archetype] == nothing return false end) 
                   for i in 1:N]
    return quote 
        $(expressions...)
        return true
    end
end
