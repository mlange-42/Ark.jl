# ------------------------------------------------------------------------
# ⚠️ This file is auto-generated. DO NOT EDIT.
# Changes will be overwritten by the code generation process.
# ------------------------------------------------------------------------

"""
    Query1{ A }

A query for 1 components.
"""
mutable struct Query1{A}
    _index::Int
    _world::World
    _ids::Tuple{UInt8}
    _mask::_Mask
    _storage_a::_ComponentStorage{A}
    _lock::UInt8
end

"""
    Query1{ A }(world::World)

Creates a query for 1 components.
"""
function Query1{A}(world::World) where {A}
    ids = (_component_id!(world, A),)
    return Query1{A}(0, world, ids, _Mask(ids...), _get_storage(world, ids[1], A), 0)
end

"""
    get_components(q::Query1{ A })::Tuple{ Column{A} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(q::Query1{A})::Tuple{Column{A}} where {A}
    return q[]
end

@inline function Base.getindex(q::Query1{A})::Tuple{Column{A}} where {A}
    a = q._storage_a.data[q._index]
    return a
end

@inline function Base.iterate(q::Query1, state::Int)
    q._index = state
    while q._index <= length(q._world._archetypes)
        archetype = q._world._archetypes[q._index]
        if _contains_all(archetype.mask, q._mask)
            return q._index, q._index + 1
        end
        q._index += 1
    end
    close(q)
    return nothing
end

@inline function Base.iterate(q::Query1)
    q._lock = _lock(q._world._lock)
    q._index = 1
    return Base.iterate(q, q._index)
end

"""
    close(q::Query1)

Closes the query and unlocks the world.
Must be called if a query is not fully iterated.
"""
function close(q::Query1)
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

"""
    Query2{ A,B }

A query for 2 components.
"""
mutable struct Query2{A,B}
    _index::Int
    _world::World
    _ids::Tuple{UInt8,UInt8}
    _mask::_Mask
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _lock::UInt8
end

"""
    Query2{ A,B }(world::World)

Creates a query for 2 components.
"""
function Query2{A,B}(world::World) where {A,B}
    ids = (_component_id!(world, A), _component_id!(world, B))
    return Query2{A,B}(
        0,
        world,
        ids,
        _Mask(ids...),
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        0,
    )
end

"""
    get_components(q::Query2{ A,B })::Tuple{ Column{A}, Column{B} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(q::Query2{A,B})::Tuple{Column{A},Column{B}} where {A,B}
    return q[]
end

@inline function Base.getindex(q::Query2{A,B})::Tuple{Column{A},Column{B}} where {A,B}
    a = q._storage_a.data[q._index]
    b = q._storage_b.data[q._index]
    return a, b
end

@inline function Base.iterate(q::Query2, state::Int)
    q._index = state
    while q._index <= length(q._world._archetypes)
        archetype = q._world._archetypes[q._index]
        if _contains_all(archetype.mask, q._mask)
            return q._index, q._index + 1
        end
        q._index += 1
    end
    close(q)
    return nothing
end

@inline function Base.iterate(q::Query2)
    q._lock = _lock(q._world._lock)
    q._index = 1
    return Base.iterate(q, q._index)
end

"""
    close(q::Query2)

Closes the query and unlocks the world.
Must be called if a query is not fully iterated.
"""
function close(q::Query2)
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

"""
    Query3{ A,B,C }

A query for 3 components.
"""
mutable struct Query3{A,B,C}
    _index::Int
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8}
    _mask::_Mask
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _lock::UInt8
end

"""
    Query3{ A,B,C }(world::World)

Creates a query for 3 components.
"""
function Query3{A,B,C}(world::World) where {A,B,C}
    ids = (_component_id!(world, A), _component_id!(world, B), _component_id!(world, C))
    return Query3{A,B,C}(
        0,
        world,
        ids,
        _Mask(ids...),
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        0,
    )
end

"""
    get_components(q::Query3{ A,B,C })::Tuple{ Column{A}, Column{B}, Column{C} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    q::Query3{A,B,C},
)::Tuple{Column{A},Column{B},Column{C}} where {A,B,C}
    return q[]
end

@inline function Base.getindex(
    q::Query3{A,B,C},
)::Tuple{Column{A},Column{B},Column{C}} where {A,B,C}
    a = q._storage_a.data[q._index]
    b = q._storage_b.data[q._index]
    c = q._storage_c.data[q._index]
    return a, b, c
end

@inline function Base.iterate(q::Query3, state::Int)
    q._index = state
    while q._index <= length(q._world._archetypes)
        archetype = q._world._archetypes[q._index]
        if _contains_all(archetype.mask, q._mask)
            return q._index, q._index + 1
        end
        q._index += 1
    end
    close(q)
    return nothing
end

@inline function Base.iterate(q::Query3)
    q._lock = _lock(q._world._lock)
    q._index = 1
    return Base.iterate(q, q._index)
end

"""
    close(q::Query3)

Closes the query and unlocks the world.
Must be called if a query is not fully iterated.
"""
function close(q::Query3)
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

"""
    Query4{ A,B,C,D }

A query for 4 components.
"""
mutable struct Query4{A,B,C,D}
    _index::Int
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8}
    _mask::_Mask
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
    _lock::UInt8
end

"""
    Query4{ A,B,C,D }(world::World)

Creates a query for 4 components.
"""
function Query4{A,B,C,D}(world::World) where {A,B,C,D}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
        _component_id!(world, C),
        _component_id!(world, D),
    )
    return Query4{A,B,C,D}(
        0,
        world,
        ids,
        _Mask(ids...),
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
        0,
    )
end

"""
    get_components(q::Query4{ A,B,C,D })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    q::Query4{A,B,C,D},
)::Tuple{Column{A},Column{B},Column{C},Column{D}} where {A,B,C,D}
    return q[]
end

@inline function Base.getindex(
    q::Query4{A,B,C,D},
)::Tuple{Column{A},Column{B},Column{C},Column{D}} where {A,B,C,D}
    a = q._storage_a.data[q._index]
    b = q._storage_b.data[q._index]
    c = q._storage_c.data[q._index]
    d = q._storage_d.data[q._index]
    return a, b, c, d
end

@inline function Base.iterate(q::Query4, state::Int)
    q._index = state
    while q._index <= length(q._world._archetypes)
        archetype = q._world._archetypes[q._index]
        if _contains_all(archetype.mask, q._mask)
            return q._index, q._index + 1
        end
        q._index += 1
    end
    close(q)
    return nothing
end

@inline function Base.iterate(q::Query4)
    q._lock = _lock(q._world._lock)
    q._index = 1
    return Base.iterate(q, q._index)
end

"""
    close(q::Query4)

Closes the query and unlocks the world.
Must be called if a query is not fully iterated.
"""
function close(q::Query4)
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

"""
    Query5{ A,B,C,D,E }

A query for 5 components.
"""
mutable struct Query5{A,B,C,D,E}
    _index::Int
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8,UInt8}
    _mask::_Mask
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
    _storage_e::_ComponentStorage{E}
    _lock::UInt8
end

"""
    Query5{ A,B,C,D,E }(world::World)

Creates a query for 5 components.
"""
function Query5{A,B,C,D,E}(world::World) where {A,B,C,D,E}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
        _component_id!(world, C),
        _component_id!(world, D),
        _component_id!(world, E),
    )
    return Query5{A,B,C,D,E}(
        0,
        world,
        ids,
        _Mask(ids...),
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
        _get_storage(world, ids[5], E),
        0,
    )
end

"""
    get_components(q::Query5{ A,B,C,D,E })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D}, Column{E} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    q::Query5{A,B,C,D,E},
)::Tuple{Column{A},Column{B},Column{C},Column{D},Column{E}} where {A,B,C,D,E}
    return q[]
end

@inline function Base.getindex(
    q::Query5{A,B,C,D,E},
)::Tuple{Column{A},Column{B},Column{C},Column{D},Column{E}} where {A,B,C,D,E}
    a = q._storage_a.data[q._index]
    b = q._storage_b.data[q._index]
    c = q._storage_c.data[q._index]
    d = q._storage_d.data[q._index]
    e = q._storage_e.data[q._index]
    return a, b, c, d, e
end

@inline function Base.iterate(q::Query5, state::Int)
    q._index = state
    while q._index <= length(q._world._archetypes)
        archetype = q._world._archetypes[q._index]
        if _contains_all(archetype.mask, q._mask)
            return q._index, q._index + 1
        end
        q._index += 1
    end
    close(q)
    return nothing
end

@inline function Base.iterate(q::Query5)
    q._lock = _lock(q._world._lock)
    q._index = 1
    return Base.iterate(q, q._index)
end

"""
    close(q::Query5)

Closes the query and unlocks the world.
Must be called if a query is not fully iterated.
"""
function close(q::Query5)
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

"""
    Query6{ A,B,C,D,E,F }

A query for 6 components.
"""
mutable struct Query6{A,B,C,D,E,F}
    _index::Int
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8,UInt8,UInt8}
    _mask::_Mask
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
    _storage_e::_ComponentStorage{E}
    _storage_f::_ComponentStorage{F}
    _lock::UInt8
end

"""
    Query6{ A,B,C,D,E,F }(world::World)

Creates a query for 6 components.
"""
function Query6{A,B,C,D,E,F}(world::World) where {A,B,C,D,E,F}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
        _component_id!(world, C),
        _component_id!(world, D),
        _component_id!(world, E),
        _component_id!(world, F),
    )
    return Query6{A,B,C,D,E,F}(
        0,
        world,
        ids,
        _Mask(ids...),
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
        _get_storage(world, ids[5], E),
        _get_storage(world, ids[6], F),
        0,
    )
end

"""
    get_components(q::Query6{ A,B,C,D,E,F })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D}, Column{E}, Column{F} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    q::Query6{A,B,C,D,E,F},
)::Tuple{Column{A},Column{B},Column{C},Column{D},Column{E},Column{F}} where {A,B,C,D,E,F}
    return q[]
end

@inline function Base.getindex(
    q::Query6{A,B,C,D,E,F},
)::Tuple{Column{A},Column{B},Column{C},Column{D},Column{E},Column{F}} where {A,B,C,D,E,F}
    a = q._storage_a.data[q._index]
    b = q._storage_b.data[q._index]
    c = q._storage_c.data[q._index]
    d = q._storage_d.data[q._index]
    e = q._storage_e.data[q._index]
    f = q._storage_f.data[q._index]
    return a, b, c, d, e, f
end

@inline function Base.iterate(q::Query6, state::Int)
    q._index = state
    while q._index <= length(q._world._archetypes)
        archetype = q._world._archetypes[q._index]
        if _contains_all(archetype.mask, q._mask)
            return q._index, q._index + 1
        end
        q._index += 1
    end
    close(q)
    return nothing
end

@inline function Base.iterate(q::Query6)
    q._lock = _lock(q._world._lock)
    q._index = 1
    return Base.iterate(q, q._index)
end

"""
    close(q::Query6)

Closes the query and unlocks the world.
Must be called if a query is not fully iterated.
"""
function close(q::Query6)
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

"""
    Query7{ A,B,C,D,E,F,G }

A query for 7 components.
"""
mutable struct Query7{A,B,C,D,E,F,G}
    _index::Int
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8}
    _mask::_Mask
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
    _storage_e::_ComponentStorage{E}
    _storage_f::_ComponentStorage{F}
    _storage_g::_ComponentStorage{G}
    _lock::UInt8
end

"""
    Query7{ A,B,C,D,E,F,G }(world::World)

Creates a query for 7 components.
"""
function Query7{A,B,C,D,E,F,G}(world::World) where {A,B,C,D,E,F,G}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
        _component_id!(world, C),
        _component_id!(world, D),
        _component_id!(world, E),
        _component_id!(world, F),
        _component_id!(world, G),
    )
    return Query7{A,B,C,D,E,F,G}(
        0,
        world,
        ids,
        _Mask(ids...),
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
        _get_storage(world, ids[5], E),
        _get_storage(world, ids[6], F),
        _get_storage(world, ids[7], G),
        0,
    )
end

"""
    get_components(q::Query7{ A,B,C,D,E,F,G })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D}, Column{E}, Column{F}, Column{G} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    q::Query7{A,B,C,D,E,F,G},
)::Tuple{
    Column{A},
    Column{B},
    Column{C},
    Column{D},
    Column{E},
    Column{F},
    Column{G},
} where {A,B,C,D,E,F,G}
    return q[]
end

@inline function Base.getindex(
    q::Query7{A,B,C,D,E,F,G},
)::Tuple{
    Column{A},
    Column{B},
    Column{C},
    Column{D},
    Column{E},
    Column{F},
    Column{G},
} where {A,B,C,D,E,F,G}
    a = q._storage_a.data[q._index]
    b = q._storage_b.data[q._index]
    c = q._storage_c.data[q._index]
    d = q._storage_d.data[q._index]
    e = q._storage_e.data[q._index]
    f = q._storage_f.data[q._index]
    g = q._storage_g.data[q._index]
    return a, b, c, d, e, f, g
end

@inline function Base.iterate(q::Query7, state::Int)
    q._index = state
    while q._index <= length(q._world._archetypes)
        archetype = q._world._archetypes[q._index]
        if _contains_all(archetype.mask, q._mask)
            return q._index, q._index + 1
        end
        q._index += 1
    end
    close(q)
    return nothing
end

@inline function Base.iterate(q::Query7)
    q._lock = _lock(q._world._lock)
    q._index = 1
    return Base.iterate(q, q._index)
end

"""
    close(q::Query7)

Closes the query and unlocks the world.
Must be called if a query is not fully iterated.
"""
function close(q::Query7)
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

"""
    Query8{ A,B,C,D,E,F,G,H }

A query for 8 components.
"""
mutable struct Query8{A,B,C,D,E,F,G,H}
    _index::Int
    _world::World
    _ids::Tuple{UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8}
    _mask::_Mask
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
    _storage_c::_ComponentStorage{C}
    _storage_d::_ComponentStorage{D}
    _storage_e::_ComponentStorage{E}
    _storage_f::_ComponentStorage{F}
    _storage_g::_ComponentStorage{G}
    _storage_h::_ComponentStorage{H}
    _lock::UInt8
end

"""
    Query8{ A,B,C,D,E,F,G,H }(world::World)

Creates a query for 8 components.
"""
function Query8{A,B,C,D,E,F,G,H}(world::World) where {A,B,C,D,E,F,G,H}
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
    return Query8{A,B,C,D,E,F,G,H}(
        0,
        world,
        ids,
        _Mask(ids...),
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
        _get_storage(world, ids[3], C),
        _get_storage(world, ids[4], D),
        _get_storage(world, ids[5], E),
        _get_storage(world, ids[6], F),
        _get_storage(world, ids[7], G),
        _get_storage(world, ids[8], H),
        0,
    )
end

"""
    get_components(q::Query8{ A,B,C,D,E,F,G,H })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D}, Column{E}, Column{F}, Column{G}, Column{H} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    q::Query8{A,B,C,D,E,F,G,H},
)::Tuple{
    Column{A},
    Column{B},
    Column{C},
    Column{D},
    Column{E},
    Column{F},
    Column{G},
    Column{H},
} where {A,B,C,D,E,F,G,H}
    return q[]
end

@inline function Base.getindex(
    q::Query8{A,B,C,D,E,F,G,H},
)::Tuple{
    Column{A},
    Column{B},
    Column{C},
    Column{D},
    Column{E},
    Column{F},
    Column{G},
    Column{H},
} where {A,B,C,D,E,F,G,H}
    a = q._storage_a.data[q._index]
    b = q._storage_b.data[q._index]
    c = q._storage_c.data[q._index]
    d = q._storage_d.data[q._index]
    e = q._storage_e.data[q._index]
    f = q._storage_f.data[q._index]
    g = q._storage_g.data[q._index]
    h = q._storage_h.data[q._index]
    return a, b, c, d, e, f, g, h
end

@inline function Base.iterate(q::Query8, state::Int)
    q._index = state
    while q._index <= length(q._world._archetypes)
        archetype = q._world._archetypes[q._index]
        if _contains_all(archetype.mask, q._mask)
            return q._index, q._index + 1
        end
        q._index += 1
    end
    close(q)
    return nothing
end

@inline function Base.iterate(q::Query8)
    q._lock = _lock(q._world._lock)
    q._index = 1
    return Base.iterate(q, q._index)
end

"""
    close(q::Query8)

Closes the query and unlocks the world.
Must be called if a query is not fully iterated.
"""
function close(q::Query8)
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

