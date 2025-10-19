
struct Map2{A,B}
    _world::World
    _ids::Vector{UInt8}
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
end

function Map2{A,B}(world::World) where {A,B}
    ids = [
        _component_id!(world, A),
        _component_id!(world, B),
    ]
    return Map2{A,B}(
        world,
        ids,
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
    )
end

function get_components(map::Map2{A,B}, entity::Entity)::Tuple{A,B} where {A,B}
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    b = map._storage_b.data[index.archetype][index.row]
    return a, b
end

function set_components!(map::Map2{A,B}, entity::Entity, a::A, b::B) where {A,B}
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = a
    map._storage_b.data[index.archetype][index.row] = b
end

function new_entity!(map::Map2{A,B}, a::A, b::B) where {A,B}
    archetype = _find_or_create_archetype!(map._world, map._ids...)
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    map._storage_b.data[archetype][index] = b
    return entity
end
