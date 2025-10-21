
struct Map{CS<:Tuple, N}
    _world::World
    _ids::NTuple{N, UInt8}
    _storage::CS
end

# TODO: this can also be generated for performance
function Map(world::World, CompsTypes::Tuple)
    ids = Tuple(_component_id!(world, C) for C in CompsTypes)
    return Map(world, ids, Tuple(_get_storage(world, id, C) for (id, C) in zip(ids,CompsTypes)))
end

@generated function get_mapped_components(map::Map{CS}, index) where {CS <: Tuple}
    N = length(CS.parameters)
    expressions = [:(map._storage[$i].data[index.archetype][index.row]) for i in 1:N]
    return Expr(:tuple, expressions...)
end

@generated function set_mapped_components!(map::Map{CS}, index, comps) where {CS <: Tuple}
    N = length(CS.parameters)
    expressions = [:(map._storage[$i].data[index.archetype][index.row] = comps[$i]) for i in 1:N]
    return quote $(expressions...) end
end

@generated function set_entity_components!(map::Map{CS}, archetype, index, comps) where {CS <: Tuple}
    N = length(CS.parameters)
    expressions = [:(map._storage[$i].data[archetype][index] = comps[$i]) for i in 1:N]
    return quote $(expressions...) end
end

@generated function has_entity_components(map::Map{CS}, index) where {CS <: Tuple}
    N = length(CS.parameters)
    expressions = [:(if map._storage[$i].data[index.archetype] == nothing return false end) 
                   for i in 1:N]
    return quote 
        $(expressions...)
        return true
    end
end

function get_components(map::Map, entity::Entity)
    return map[entity]
end

function remove_components!(map::Map, entity::Entity)
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

function set_components!(map::Map, entity::Entity, values)
    map[entity] = values
end

@inline function Base.getindex(map::Map, entity::Entity)
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    return get_mapped_components(map, index)
end

function new_entity!(map::Map, comps::Tuple)
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].node, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    set_entity_components!(map, archetype, index, comps)
    return entity
end

function add_components!(map::Map, entity::Entity, value)
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    set_entity_components!(map, archetype, row, value)
end

@inline function Base.setindex!(map::Map, value, entity::Entity)
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    set_mapped_components!(map, index, value)
end

function has_components(map::Map, entity::Entity)
    if !is_alive(map._world, entity)
        error("can't check components of a dead entity")
    end
    index = map._world._entities[entity._id]
    return has_entity_components(map, index)
end
