# ------------------------------------------------------------------------
# ⚠️ This file is auto-generated. DO NOT EDIT.
# Changes will be overwritten by the code generation process.
# ------------------------------------------------------------------------

"""
    Map1{ A }

A component mapper for 1 components.
"""
struct Map1{A}
    _world::World
    _ids::Tuple{UInt8}
    _storage_a::_ComponentStorage{A}
end

"""
    Map1{ A }(world::World)

Creates a component mapper for 1 components.
"""
function Map1{A}(world::World) where {A}
    ids = (_component_id!(world, A),)
    return Map1{A}(world, ids, _get_storage(world, ids[1], A))
end

"""
    new_entity!(map::Map1{ A }, a::A)::Entity

Creates a new [`Entity`](@ref) with 1 components.
"""
function new_entity!(map::Map1{A}, a::A)::Entity where {A}
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].mask, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    return entity
end

"""
    get_components(map::Map1{ A }, entity::Entity)::Tuple{ A }

Get 1 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
pos, vel = map[entity]
```
"""
@inline function get_components(map::Map1{A}, entity::Entity)::Tuple{A} where {A}
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

"""
    Map2{ A,B }

A component mapper for 2 components.
"""
struct Map2{A,B}
    _world::World
    _ids::Tuple{UInt8,UInt8}
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
end

"""
    Map2{ A,B }(world::World)

Creates a component mapper for 2 components.
"""
function Map2{A,B}(world::World) where {A,B}
    ids = (_component_id!(world, A), _component_id!(world, B))
    return Map2{A,B}(
        world,
        ids,
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
    )
end

"""
    new_entity!(map::Map2{ A,B }, a::A, b::B)::Entity

Creates a new [`Entity`](@ref) with 2 components.
"""
function new_entity!(map::Map2{A,B}, a::A, b::B)::Entity where {A,B}
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].mask, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    map._storage_b.data[archetype][index] = b
    return entity
end

"""
    get_components(map::Map2{ A,B }, entity::Entity)::Tuple{ A,B }

Get 2 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
pos, vel = map[entity]
```
"""
@inline function get_components(map::Map2{A,B}, entity::Entity)::Tuple{A,B} where {A,B}
    return map[entity]
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

"""
    has_components!(map::Map2{ A,B }, entity::Entity)

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
    add_components!(map::Map2{ A,B }, a::A, b::B)::Entity

Adds 2 components to an [`Entity`](@ref).
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
    remove_components!(map::Map2{ A,B }, entity::Entity)

Removes 2 components from an [`Entity`](@ref).
"""
function remove_components!(map::Map2{A,B}, entity::Entity) where {A,B}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

"""
    Map3{ A,B,C }

A component mapper for 3 components.
"""
struct Map3{A,B,C}
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8}
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
end

"""
    Map3{ A,B,C }(world::World)

Creates a component mapper for 3 components.
"""
function Map3{A,B,C}(world::World) where {A,B,C}
    ids = (_component_id!(world, A), _component_id!(world, B), _component_id!(world, C))
    return Map3{A,B,C}(
        world,
        ids,
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
    )
end

"""
    new_entity!(map::Map3{ A,B,C }, a::A, b::B, c::C)::Entity

Creates a new [`Entity`](@ref) with 3 components.
"""
function new_entity!(map::Map3{A,B,C}, a::A, b::B, c::C)::Entity where {A,B,C}
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].mask, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    map._storage_b.data[archetype][index] = b
    map._storage_c.data[archetype][index] = c
    return entity
end

"""
    get_components(map::Map3{ A,B,C }, entity::Entity)::Tuple{ A,B,C }

Get 3 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
pos, vel = map[entity]
```
"""
@inline function get_components(
    map::Map3{A,B,C},
    entity::Entity,
)::Tuple{A,B,C} where {A,B,C}
    return map[entity]
end

@inline function Base.getindex(map::Map3{A,B,C}, entity::Entity)::Tuple{A,B,C} where {A,B,C}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    b = map._storage_b.data[index.archetype][index.row]
    c = map._storage_c.data[index.archetype][index.row]
    return a, b, c
end

"""
    set_components!(map::Map3{ A,B,C }, entity::Entity, a::A, b::B, c::C)

Set 3 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
map[entity] = (Position(0, 0), Velocity(1, 1))
```
"""
function set_components!(map::Map3{A,B,C}, entity::Entity, a::A, b::B, c::C) where {A,B,C}
    map[entity] = (a, b, c)
end

@inline function Base.setindex!(
    map::Map3{A,B,C},
    value::Tuple{A,B,C},
    entity::Entity,
) where {A,B,C}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = value[1]
    map._storage_b.data[index.archetype][index.row] = value[2]
    map._storage_c.data[index.archetype][index.row] = value[3]
end

"""
    has_components!(map::Map3{ A,B,C }, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
function has_components(map::Map3{A,B,C}, entity::Entity) where {A,B,C}
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
    if map._storage_c.data[index.archetype] == nothing
        return false
    end
    return true
end

"""
    add_components!(map::Map3{ A,B,C }, a::A, b::B, c::C)::Entity

Adds 3 components to an [`Entity`](@ref).
"""
function add_components!(map::Map3{A,B,C}, entity::Entity, a::A, b::B, c::C) where {A,B,C}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    map._storage_a.data[archetype][row] = a
    map._storage_b.data[archetype][row] = b
    map._storage_c.data[archetype][row] = c
end

"""
    remove_components!(map::Map3{ A,B,C }, entity::Entity)

Removes 3 components from an [`Entity`](@ref).
"""
function remove_components!(map::Map3{A,B,C}, entity::Entity) where {A,B,C}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

"""
    Map4{ A,B,C,D }

A component mapper for 4 components.
"""
struct Map4{A,B,C,D}
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8}
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
end

"""
    Map4{ A,B,C,D }(world::World)

Creates a component mapper for 4 components.
"""
function Map4{A,B,C,D}(world::World) where {A,B,C,D}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
        _component_id!(world, C),
        _component_id!(world, D),
    )
    return Map4{A,B,C,D}(
        world,
        ids,
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
    )
end

"""
    new_entity!(map::Map4{ A,B,C,D }, a::A, b::B, c::C, d::D)::Entity

Creates a new [`Entity`](@ref) with 4 components.
"""
function new_entity!(map::Map4{A,B,C,D}, a::A, b::B, c::C, d::D)::Entity where {A,B,C,D}
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].mask, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    map._storage_b.data[archetype][index] = b
    map._storage_c.data[archetype][index] = c
    map._storage_d.data[archetype][index] = d
    return entity
end

"""
    get_components(map::Map4{ A,B,C,D }, entity::Entity)::Tuple{ A,B,C,D }

Get 4 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
pos, vel = map[entity]
```
"""
@inline function get_components(
    map::Map4{A,B,C,D},
    entity::Entity,
)::Tuple{A,B,C,D} where {A,B,C,D}
    return map[entity]
end

@inline function Base.getindex(
    map::Map4{A,B,C,D},
    entity::Entity,
)::Tuple{A,B,C,D} where {A,B,C,D}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    b = map._storage_b.data[index.archetype][index.row]
    c = map._storage_c.data[index.archetype][index.row]
    d = map._storage_d.data[index.archetype][index.row]
    return a, b, c, d
end

"""
    set_components!(map::Map4{ A,B,C,D }, entity::Entity, a::A, b::B, c::C, d::D)

Set 4 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
map[entity] = (Position(0, 0), Velocity(1, 1))
```
"""
function set_components!(
    map::Map4{A,B,C,D},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
) where {A,B,C,D}
    map[entity] = (a, b, c, d)
end

@inline function Base.setindex!(
    map::Map4{A,B,C,D},
    value::Tuple{A,B,C,D},
    entity::Entity,
) where {A,B,C,D}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = value[1]
    map._storage_b.data[index.archetype][index.row] = value[2]
    map._storage_c.data[index.archetype][index.row] = value[3]
    map._storage_d.data[index.archetype][index.row] = value[4]
end

"""
    has_components!(map::Map4{ A,B,C,D }, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
function has_components(map::Map4{A,B,C,D}, entity::Entity) where {A,B,C,D}
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
    if map._storage_c.data[index.archetype] == nothing
        return false
    end
    if map._storage_d.data[index.archetype] == nothing
        return false
    end
    return true
end

"""
    add_components!(map::Map4{ A,B,C,D }, a::A, b::B, c::C, d::D)::Entity

Adds 4 components to an [`Entity`](@ref).
"""
function add_components!(
    map::Map4{A,B,C,D},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
) where {A,B,C,D}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    map._storage_a.data[archetype][row] = a
    map._storage_b.data[archetype][row] = b
    map._storage_c.data[archetype][row] = c
    map._storage_d.data[archetype][row] = d
end

"""
    remove_components!(map::Map4{ A,B,C,D }, entity::Entity)

Removes 4 components from an [`Entity`](@ref).
"""
function remove_components!(map::Map4{A,B,C,D}, entity::Entity) where {A,B,C,D}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

"""
    Map5{ A,B,C,D,E }

A component mapper for 5 components.
"""
struct Map5{A,B,C,D,E}
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8,UInt8}
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
    _storage_e::_ComponentStorage{E}
end

"""
    Map5{ A,B,C,D,E }(world::World)

Creates a component mapper for 5 components.
"""
function Map5{A,B,C,D,E}(world::World) where {A,B,C,D,E}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
        _component_id!(world, C),
        _component_id!(world, D),
        _component_id!(world, E),
    )
    return Map5{A,B,C,D,E}(
        world,
        ids,
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
        _get_storage(world, ids[5], E),
    )
end

"""
    new_entity!(map::Map5{ A,B,C,D,E }, a::A, b::B, c::C, d::D, e::E)::Entity

Creates a new [`Entity`](@ref) with 5 components.
"""
function new_entity!(
    map::Map5{A,B,C,D,E},
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
)::Entity where {A,B,C,D,E}
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].mask, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    map._storage_b.data[archetype][index] = b
    map._storage_c.data[archetype][index] = c
    map._storage_d.data[archetype][index] = d
    map._storage_e.data[archetype][index] = e
    return entity
end

"""
    get_components(map::Map5{ A,B,C,D,E }, entity::Entity)::Tuple{ A,B,C,D,E }

Get 5 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
pos, vel = map[entity]
```
"""
@inline function get_components(
    map::Map5{A,B,C,D,E},
    entity::Entity,
)::Tuple{A,B,C,D,E} where {A,B,C,D,E}
    return map[entity]
end

@inline function Base.getindex(
    map::Map5{A,B,C,D,E},
    entity::Entity,
)::Tuple{A,B,C,D,E} where {A,B,C,D,E}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    b = map._storage_b.data[index.archetype][index.row]
    c = map._storage_c.data[index.archetype][index.row]
    d = map._storage_d.data[index.archetype][index.row]
    e = map._storage_e.data[index.archetype][index.row]
    return a, b, c, d, e
end

"""
    set_components!(map::Map5{ A,B,C,D,E }, entity::Entity, a::A, b::B, c::C, d::D, e::E)

Set 5 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
map[entity] = (Position(0, 0), Velocity(1, 1))
```
"""
function set_components!(
    map::Map5{A,B,C,D,E},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
) where {A,B,C,D,E}
    map[entity] = (a, b, c, d, e)
end

@inline function Base.setindex!(
    map::Map5{A,B,C,D,E},
    value::Tuple{A,B,C,D,E},
    entity::Entity,
) where {A,B,C,D,E}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = value[1]
    map._storage_b.data[index.archetype][index.row] = value[2]
    map._storage_c.data[index.archetype][index.row] = value[3]
    map._storage_d.data[index.archetype][index.row] = value[4]
    map._storage_e.data[index.archetype][index.row] = value[5]
end

"""
    has_components!(map::Map5{ A,B,C,D,E }, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
function has_components(map::Map5{A,B,C,D,E}, entity::Entity) where {A,B,C,D,E}
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
    if map._storage_c.data[index.archetype] == nothing
        return false
    end
    if map._storage_d.data[index.archetype] == nothing
        return false
    end
    if map._storage_e.data[index.archetype] == nothing
        return false
    end
    return true
end

"""
    add_components!(map::Map5{ A,B,C,D,E }, a::A, b::B, c::C, d::D, e::E)::Entity

Adds 5 components to an [`Entity`](@ref).
"""
function add_components!(
    map::Map5{A,B,C,D,E},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
) where {A,B,C,D,E}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    map._storage_a.data[archetype][row] = a
    map._storage_b.data[archetype][row] = b
    map._storage_c.data[archetype][row] = c
    map._storage_d.data[archetype][row] = d
    map._storage_e.data[archetype][row] = e
end

"""
    remove_components!(map::Map5{ A,B,C,D,E }, entity::Entity)

Removes 5 components from an [`Entity`](@ref).
"""
function remove_components!(map::Map5{A,B,C,D,E}, entity::Entity) where {A,B,C,D,E}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

"""
    Map6{ A,B,C,D,E,F }

A component mapper for 6 components.
"""
struct Map6{A,B,C,D,E,F}
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8,UInt8,UInt8}
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
    _storage_e::_ComponentStorage{E}
    _storage_f::_ComponentStorage{F}
end

"""
    Map6{ A,B,C,D,E,F }(world::World)

Creates a component mapper for 6 components.
"""
function Map6{A,B,C,D,E,F}(world::World) where {A,B,C,D,E,F}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
        _component_id!(world, C),
        _component_id!(world, D),
        _component_id!(world, E),
        _component_id!(world, F),
    )
    return Map6{A,B,C,D,E,F}(
        world,
        ids,
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
        _get_storage(world, ids[5], E),
        _get_storage(world, ids[6], F),
    )
end

"""
    new_entity!(map::Map6{ A,B,C,D,E,F }, a::A, b::B, c::C, d::D, e::E, f::F)::Entity

Creates a new [`Entity`](@ref) with 6 components.
"""
function new_entity!(
    map::Map6{A,B,C,D,E,F},
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
    f::F,
)::Entity where {A,B,C,D,E,F}
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].mask, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    map._storage_b.data[archetype][index] = b
    map._storage_c.data[archetype][index] = c
    map._storage_d.data[archetype][index] = d
    map._storage_e.data[archetype][index] = e
    map._storage_f.data[archetype][index] = f
    return entity
end

"""
    get_components(map::Map6{ A,B,C,D,E,F }, entity::Entity)::Tuple{ A,B,C,D,E,F }

Get 6 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
pos, vel = map[entity]
```
"""
@inline function get_components(
    map::Map6{A,B,C,D,E,F},
    entity::Entity,
)::Tuple{A,B,C,D,E,F} where {A,B,C,D,E,F}
    return map[entity]
end

@inline function Base.getindex(
    map::Map6{A,B,C,D,E,F},
    entity::Entity,
)::Tuple{A,B,C,D,E,F} where {A,B,C,D,E,F}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    b = map._storage_b.data[index.archetype][index.row]
    c = map._storage_c.data[index.archetype][index.row]
    d = map._storage_d.data[index.archetype][index.row]
    e = map._storage_e.data[index.archetype][index.row]
    f = map._storage_f.data[index.archetype][index.row]
    return a, b, c, d, e, f
end

"""
    set_components!(map::Map6{ A,B,C,D,E,F }, entity::Entity, a::A, b::B, c::C, d::D, e::E, f::F)

Set 6 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
map[entity] = (Position(0, 0), Velocity(1, 1))
```
"""
function set_components!(
    map::Map6{A,B,C,D,E,F},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
    f::F,
) where {A,B,C,D,E,F}
    map[entity] = (a, b, c, d, e, f)
end

@inline function Base.setindex!(
    map::Map6{A,B,C,D,E,F},
    value::Tuple{A,B,C,D,E,F},
    entity::Entity,
) where {A,B,C,D,E,F}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = value[1]
    map._storage_b.data[index.archetype][index.row] = value[2]
    map._storage_c.data[index.archetype][index.row] = value[3]
    map._storage_d.data[index.archetype][index.row] = value[4]
    map._storage_e.data[index.archetype][index.row] = value[5]
    map._storage_f.data[index.archetype][index.row] = value[6]
end

"""
    has_components!(map::Map6{ A,B,C,D,E,F }, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
function has_components(map::Map6{A,B,C,D,E,F}, entity::Entity) where {A,B,C,D,E,F}
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
    if map._storage_c.data[index.archetype] == nothing
        return false
    end
    if map._storage_d.data[index.archetype] == nothing
        return false
    end
    if map._storage_e.data[index.archetype] == nothing
        return false
    end
    if map._storage_f.data[index.archetype] == nothing
        return false
    end
    return true
end

"""
    add_components!(map::Map6{ A,B,C,D,E,F }, a::A, b::B, c::C, d::D, e::E, f::F)::Entity

Adds 6 components to an [`Entity`](@ref).
"""
function add_components!(
    map::Map6{A,B,C,D,E,F},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
    f::F,
) where {A,B,C,D,E,F}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    map._storage_a.data[archetype][row] = a
    map._storage_b.data[archetype][row] = b
    map._storage_c.data[archetype][row] = c
    map._storage_d.data[archetype][row] = d
    map._storage_e.data[archetype][row] = e
    map._storage_f.data[archetype][row] = f
end

"""
    remove_components!(map::Map6{ A,B,C,D,E,F }, entity::Entity)

Removes 6 components from an [`Entity`](@ref).
"""
function remove_components!(map::Map6{A,B,C,D,E,F}, entity::Entity) where {A,B,C,D,E,F}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

"""
    Map7{ A,B,C,D,E,F,G }

A component mapper for 7 components.
"""
struct Map7{A,B,C,D,E,F,G}
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8}
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
    _storage_e::_ComponentStorage{E}
    _storage_f::_ComponentStorage{F}
    _storage_g::_ComponentStorage{G}
end

"""
    Map7{ A,B,C,D,E,F,G }(world::World)

Creates a component mapper for 7 components.
"""
function Map7{A,B,C,D,E,F,G}(world::World) where {A,B,C,D,E,F,G}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
        _component_id!(world, C),
        _component_id!(world, D),
        _component_id!(world, E),
        _component_id!(world, F),
        _component_id!(world, G),
    )
    return Map7{A,B,C,D,E,F,G}(
        world,
        ids,
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
        _get_storage(world, ids[5], E),
        _get_storage(world, ids[6], F),
        _get_storage(world, ids[7], G),
    )
end

"""
    new_entity!(map::Map7{ A,B,C,D,E,F,G }, a::A, b::B, c::C, d::D, e::E, f::F, g::G)::Entity

Creates a new [`Entity`](@ref) with 7 components.
"""
function new_entity!(
    map::Map7{A,B,C,D,E,F,G},
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
    f::F,
    g::G,
)::Entity where {A,B,C,D,E,F,G}
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].mask, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    map._storage_b.data[archetype][index] = b
    map._storage_c.data[archetype][index] = c
    map._storage_d.data[archetype][index] = d
    map._storage_e.data[archetype][index] = e
    map._storage_f.data[archetype][index] = f
    map._storage_g.data[archetype][index] = g
    return entity
end

"""
    get_components(map::Map7{ A,B,C,D,E,F,G }, entity::Entity)::Tuple{ A,B,C,D,E,F,G }

Get 7 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
pos, vel = map[entity]
```
"""
@inline function get_components(
    map::Map7{A,B,C,D,E,F,G},
    entity::Entity,
)::Tuple{A,B,C,D,E,F,G} where {A,B,C,D,E,F,G}
    return map[entity]
end

@inline function Base.getindex(
    map::Map7{A,B,C,D,E,F,G},
    entity::Entity,
)::Tuple{A,B,C,D,E,F,G} where {A,B,C,D,E,F,G}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    b = map._storage_b.data[index.archetype][index.row]
    c = map._storage_c.data[index.archetype][index.row]
    d = map._storage_d.data[index.archetype][index.row]
    e = map._storage_e.data[index.archetype][index.row]
    f = map._storage_f.data[index.archetype][index.row]
    g = map._storage_g.data[index.archetype][index.row]
    return a, b, c, d, e, f, g
end

"""
    set_components!(map::Map7{ A,B,C,D,E,F,G }, entity::Entity, a::A, b::B, c::C, d::D, e::E, f::F, g::G)

Set 7 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
map[entity] = (Position(0, 0), Velocity(1, 1))
```
"""
function set_components!(
    map::Map7{A,B,C,D,E,F,G},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
    f::F,
    g::G,
) where {A,B,C,D,E,F,G}
    map[entity] = (a, b, c, d, e, f, g)
end

@inline function Base.setindex!(
    map::Map7{A,B,C,D,E,F,G},
    value::Tuple{A,B,C,D,E,F,G},
    entity::Entity,
) where {A,B,C,D,E,F,G}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = value[1]
    map._storage_b.data[index.archetype][index.row] = value[2]
    map._storage_c.data[index.archetype][index.row] = value[3]
    map._storage_d.data[index.archetype][index.row] = value[4]
    map._storage_e.data[index.archetype][index.row] = value[5]
    map._storage_f.data[index.archetype][index.row] = value[6]
    map._storage_g.data[index.archetype][index.row] = value[7]
end

"""
    has_components!(map::Map7{ A,B,C,D,E,F,G }, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
function has_components(map::Map7{A,B,C,D,E,F,G}, entity::Entity) where {A,B,C,D,E,F,G}
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
    if map._storage_c.data[index.archetype] == nothing
        return false
    end
    if map._storage_d.data[index.archetype] == nothing
        return false
    end
    if map._storage_e.data[index.archetype] == nothing
        return false
    end
    if map._storage_f.data[index.archetype] == nothing
        return false
    end
    if map._storage_g.data[index.archetype] == nothing
        return false
    end
    return true
end

"""
    add_components!(map::Map7{ A,B,C,D,E,F,G }, a::A, b::B, c::C, d::D, e::E, f::F, g::G)::Entity

Adds 7 components to an [`Entity`](@ref).
"""
function add_components!(
    map::Map7{A,B,C,D,E,F,G},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
    f::F,
    g::G,
) where {A,B,C,D,E,F,G}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    map._storage_a.data[archetype][row] = a
    map._storage_b.data[archetype][row] = b
    map._storage_c.data[archetype][row] = c
    map._storage_d.data[archetype][row] = d
    map._storage_e.data[archetype][row] = e
    map._storage_f.data[archetype][row] = f
    map._storage_g.data[archetype][row] = g
end

"""
    remove_components!(map::Map7{ A,B,C,D,E,F,G }, entity::Entity)

Removes 7 components from an [`Entity`](@ref).
"""
function remove_components!(map::Map7{A,B,C,D,E,F,G}, entity::Entity) where {A,B,C,D,E,F,G}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

"""
    Map8{ A,B,C,D,E,F,G,H }

A component mapper for 8 components.
"""
struct Map8{A,B,C,D,E,F,G,H}
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8}
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
    _storage_e::_ComponentStorage{E}
    _storage_f::_ComponentStorage{F}
    _storage_g::_ComponentStorage{G}
    _storage_h::_ComponentStorage{H}
end

"""
    Map8{ A,B,C,D,E,F,G,H }(world::World)

Creates a component mapper for 8 components.
"""
function Map8{A,B,C,D,E,F,G,H}(world::World) where {A,B,C,D,E,F,G,H}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
        _component_id!(world, C),
        _component_id!(world, D),
        _component_id!(world, E),
        _component_id!(world, F),
        _component_id!(world, G),
        _component_id!(world, H),
    )
    return Map8{A,B,C,D,E,F,G,H}(
        world,
        ids,
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
        _get_storage(world, ids[5], E),
        _get_storage(world, ids[6], F),
        _get_storage(world, ids[7], G),
        _get_storage(world, ids[8], H),
    )
end

"""
    new_entity!(map::Map8{ A,B,C,D,E,F,G,H }, a::A, b::B, c::C, d::D, e::E, f::F, g::G, h::H)::Entity

Creates a new [`Entity`](@ref) with 8 components.
"""
function new_entity!(
    map::Map8{A,B,C,D,E,F,G,H},
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
    f::F,
    g::G,
    h::H,
)::Entity where {A,B,C,D,E,F,G,H}
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].mask, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    map._storage_a.data[archetype][index] = a
    map._storage_b.data[archetype][index] = b
    map._storage_c.data[archetype][index] = c
    map._storage_d.data[archetype][index] = d
    map._storage_e.data[archetype][index] = e
    map._storage_f.data[archetype][index] = f
    map._storage_g.data[archetype][index] = g
    map._storage_h.data[archetype][index] = h
    return entity
end

"""
    get_components(map::Map8{ A,B,C,D,E,F,G,H }, entity::Entity)::Tuple{ A,B,C,D,E,F,G,H }

Get 8 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
pos, vel = map[entity]
```
"""
@inline function get_components(
    map::Map8{A,B,C,D,E,F,G,H},
    entity::Entity,
)::Tuple{A,B,C,D,E,F,G,H} where {A,B,C,D,E,F,G,H}
    return map[entity]
end

@inline function Base.getindex(
    map::Map8{A,B,C,D,E,F,G,H},
    entity::Entity,
)::Tuple{A,B,C,D,E,F,G,H} where {A,B,C,D,E,F,G,H}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    a = map._storage_a.data[index.archetype][index.row]
    b = map._storage_b.data[index.archetype][index.row]
    c = map._storage_c.data[index.archetype][index.row]
    d = map._storage_d.data[index.archetype][index.row]
    e = map._storage_e.data[index.archetype][index.row]
    f = map._storage_f.data[index.archetype][index.row]
    g = map._storage_g.data[index.archetype][index.row]
    h = map._storage_h.data[index.archetype][index.row]
    return a, b, c, d, e, f, g, h
end

"""
    set_components!(map::Map8{ A,B,C,D,E,F,G,H }, entity::Entity, a::A, b::B, c::C, d::D, e::E, f::F, g::G, h::H)

Set 8 components of an [`Entity`](@ref).

Alternatively, use indexing:

```julia
map[entity] = (Position(0, 0), Velocity(1, 1))
```
"""
function set_components!(
    map::Map8{A,B,C,D,E,F,G,H},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
    f::F,
    g::G,
    h::H,
) where {A,B,C,D,E,F,G,H}
    map[entity] = (a, b, c, d, e, f, g, h)
end

@inline function Base.setindex!(
    map::Map8{A,B,C,D,E,F,G,H},
    value::Tuple{A,B,C,D,E,F,G,H},
    entity::Entity,
) where {A,B,C,D,E,F,G,H}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    map._storage_a.data[index.archetype][index.row] = value[1]
    map._storage_b.data[index.archetype][index.row] = value[2]
    map._storage_c.data[index.archetype][index.row] = value[3]
    map._storage_d.data[index.archetype][index.row] = value[4]
    map._storage_e.data[index.archetype][index.row] = value[5]
    map._storage_f.data[index.archetype][index.row] = value[6]
    map._storage_g.data[index.archetype][index.row] = value[7]
    map._storage_h.data[index.archetype][index.row] = value[8]
end

"""
    has_components!(map::Map8{ A,B,C,D,E,F,G,H }, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
function has_components(map::Map8{A,B,C,D,E,F,G,H}, entity::Entity) where {A,B,C,D,E,F,G,H}
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
    if map._storage_c.data[index.archetype] == nothing
        return false
    end
    if map._storage_d.data[index.archetype] == nothing
        return false
    end
    if map._storage_e.data[index.archetype] == nothing
        return false
    end
    if map._storage_f.data[index.archetype] == nothing
        return false
    end
    if map._storage_g.data[index.archetype] == nothing
        return false
    end
    if map._storage_h.data[index.archetype] == nothing
        return false
    end
    return true
end

"""
    add_components!(map::Map8{ A,B,C,D,E,F,G,H }, a::A, b::B, c::C, d::D, e::E, f::F, g::G, h::H)::Entity

Adds 8 components to an [`Entity`](@ref).
"""
function add_components!(
    map::Map8{A,B,C,D,E,F,G,H},
    entity::Entity,
    a::A,
    b::B,
    c::C,
    d::D,
    e::E,
    f::F,
    g::G,
    h::H,
) where {A,B,C,D,E,F,G,H}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    map._storage_a.data[archetype][row] = a
    map._storage_b.data[archetype][row] = b
    map._storage_c.data[archetype][row] = c
    map._storage_d.data[archetype][row] = d
    map._storage_e.data[archetype][row] = e
    map._storage_f.data[archetype][row] = f
    map._storage_g.data[archetype][row] = g
    map._storage_h.data[archetype][row] = h
end

"""
    remove_components!(map::Map8{ A,B,C,D,E,F,G,H }, entity::Entity)

Removes 8 components from an [`Entity`](@ref).
"""
function remove_components!(
    map::Map8{A,B,C,D,E,F,G,H},
    entity::Entity,
) where {A,B,C,D,E,F,G,H}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

