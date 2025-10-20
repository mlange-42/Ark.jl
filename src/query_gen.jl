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
end

"""
    Query1{ A }(world::World)

Creates a query for 1 components.
"""
function Query1{A}(world::World) where {A}
    ids = (_component_id!(world, A),)
    return Query1{A}(0, world, ids, _Mask(ids...), _get_storage(world, ids[1], A))
end

"""
    get_components(f::Query1{ A })::Tuple{ Column{A} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(f::Query1{A})::Tuple{Column{A}} where {A}
    return f[]
end

@inline function Base.getindex(f::Query1{A})::Tuple{Column{A}} where {A}
    a = f._storage_a.data[f._index]
    return a
end

@inline function Base.iterate(f::Query1, state::Int)
    f._index = state
    while f._index <= length(f._world._archetypes)
        archetype = f._world._archetypes[f._index]
        if _contains_all(archetype.mask, f._mask)
            return f._index, f._index + 1
        end
        f._index += 1
    end
    f._index = 0
    return nothing
end

@inline function Base.iterate(f::Query1)
    f._index = 1
    return Base.iterate(f, f._index)
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
    )
end

"""
    get_components(f::Query2{ A,B })::Tuple{ Column{A}, Column{B} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(f::Query2{A,B})::Tuple{Column{A},Column{B}} where {A,B}
    return f[]
end

@inline function Base.getindex(f::Query2{A,B})::Tuple{Column{A},Column{B}} where {A,B}
    a = f._storage_a.data[f._index]
    b = f._storage_b.data[f._index]
    return a, b
end

@inline function Base.iterate(f::Query2, state::Int)
    f._index = state
    while f._index <= length(f._world._archetypes)
        archetype = f._world._archetypes[f._index]
        if _contains_all(archetype.mask, f._mask)
            return f._index, f._index + 1
        end
        f._index += 1
    end
    f._index = 0
    return nothing
end

@inline function Base.iterate(f::Query2)
    f._index = 1
    return Base.iterate(f, f._index)
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
    )
end

"""
    get_components(f::Query3{ A,B,C })::Tuple{ Column{A}, Column{B}, Column{C} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    f::Query3{A,B,C},
)::Tuple{Column{A},Column{B},Column{C}} where {A,B,C}
    return f[]
end

@inline function Base.getindex(
    f::Query3{A,B,C},
)::Tuple{Column{A},Column{B},Column{C}} where {A,B,C}
    a = f._storage_a.data[f._index]
    b = f._storage_b.data[f._index]
    c = f._storage_c.data[f._index]
    return a, b, c
end

@inline function Base.iterate(f::Query3, state::Int)
    f._index = state
    while f._index <= length(f._world._archetypes)
        archetype = f._world._archetypes[f._index]
        if _contains_all(archetype.mask, f._mask)
            return f._index, f._index + 1
        end
        f._index += 1
    end
    f._index = 0
    return nothing
end

@inline function Base.iterate(f::Query3)
    f._index = 1
    return Base.iterate(f, f._index)
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
    )
end

"""
    get_components(f::Query4{ A,B,C,D })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    f::Query4{A,B,C,D},
)::Tuple{Column{A},Column{B},Column{C},Column{D}} where {A,B,C,D}
    return f[]
end

@inline function Base.getindex(
    f::Query4{A,B,C,D},
)::Tuple{Column{A},Column{B},Column{C},Column{D}} where {A,B,C,D}
    a = f._storage_a.data[f._index]
    b = f._storage_b.data[f._index]
    c = f._storage_c.data[f._index]
    d = f._storage_d.data[f._index]
    return a, b, c, d
end

@inline function Base.iterate(f::Query4, state::Int)
    f._index = state
    while f._index <= length(f._world._archetypes)
        archetype = f._world._archetypes[f._index]
        if _contains_all(archetype.mask, f._mask)
            return f._index, f._index + 1
        end
        f._index += 1
    end
    f._index = 0
    return nothing
end

@inline function Base.iterate(f::Query4)
    f._index = 1
    return Base.iterate(f, f._index)
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
    )
end

"""
    get_components(f::Query5{ A,B,C,D,E })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D}, Column{E} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    f::Query5{A,B,C,D,E},
)::Tuple{Column{A},Column{B},Column{C},Column{D},Column{E}} where {A,B,C,D,E}
    return f[]
end

@inline function Base.getindex(
    f::Query5{A,B,C,D,E},
)::Tuple{Column{A},Column{B},Column{C},Column{D},Column{E}} where {A,B,C,D,E}
    a = f._storage_a.data[f._index]
    b = f._storage_b.data[f._index]
    c = f._storage_c.data[f._index]
    d = f._storage_d.data[f._index]
    e = f._storage_e.data[f._index]
    return a, b, c, d, e
end

@inline function Base.iterate(f::Query5, state::Int)
    f._index = state
    while f._index <= length(f._world._archetypes)
        archetype = f._world._archetypes[f._index]
        if _contains_all(archetype.mask, f._mask)
            return f._index, f._index + 1
        end
        f._index += 1
    end
    f._index = 0
    return nothing
end

@inline function Base.iterate(f::Query5)
    f._index = 1
    return Base.iterate(f, f._index)
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
    )
end

"""
    get_components(f::Query6{ A,B,C,D,E,F })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D}, Column{E}, Column{F} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    f::Query6{A,B,C,D,E,F},
)::Tuple{Column{A},Column{B},Column{C},Column{D},Column{E},Column{F}} where {A,B,C,D,E,F}
    return f[]
end

@inline function Base.getindex(
    f::Query6{A,B,C,D,E,F},
)::Tuple{Column{A},Column{B},Column{C},Column{D},Column{E},Column{F}} where {A,B,C,D,E,F}
    a = f._storage_a.data[f._index]
    b = f._storage_b.data[f._index]
    c = f._storage_c.data[f._index]
    d = f._storage_d.data[f._index]
    e = f._storage_e.data[f._index]
    f = f._storage_f.data[f._index]
    return a, b, c, d, e, f
end

@inline function Base.iterate(f::Query6, state::Int)
    f._index = state
    while f._index <= length(f._world._archetypes)
        archetype = f._world._archetypes[f._index]
        if _contains_all(archetype.mask, f._mask)
            return f._index, f._index + 1
        end
        f._index += 1
    end
    f._index = 0
    return nothing
end

@inline function Base.iterate(f::Query6)
    f._index = 1
    return Base.iterate(f, f._index)
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
    )
end

"""
    get_components(f::Query7{ A,B,C,D,E,F,G })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D}, Column{E}, Column{F}, Column{G} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    f::Query7{A,B,C,D,E,F,G},
)::Tuple{
    Column{A},
    Column{B},
    Column{C},
    Column{D},
    Column{E},
    Column{F},
    Column{G},
} where {A,B,C,D,E,F,G}
    return f[]
end

@inline function Base.getindex(
    f::Query7{A,B,C,D,E,F,G},
)::Tuple{
    Column{A},
    Column{B},
    Column{C},
    Column{D},
    Column{E},
    Column{F},
    Column{G},
} where {A,B,C,D,E,F,G}
    a = f._storage_a.data[f._index]
    b = f._storage_b.data[f._index]
    c = f._storage_c.data[f._index]
    d = f._storage_d.data[f._index]
    e = f._storage_e.data[f._index]
    f = f._storage_f.data[f._index]
    g = f._storage_g.data[f._index]
    return a, b, c, d, e, f, g
end

@inline function Base.iterate(f::Query7, state::Int)
    f._index = state
    while f._index <= length(f._world._archetypes)
        archetype = f._world._archetypes[f._index]
        if _contains_all(archetype.mask, f._mask)
            return f._index, f._index + 1
        end
        f._index += 1
    end
    f._index = 0
    return nothing
end

@inline function Base.iterate(f::Query7)
    f._index = 1
    return Base.iterate(f, f._index)
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
    )
end

"""
    get_components(f::Query8{ A,B,C,D,E,F,G,H })::Tuple{ Column{A}, Column{B}, Column{C}, Column{D}, Column{E}, Column{F}, Column{G}, Column{H} }

Returns the component columns of the archetype at the current cursor position.
"""
@inline function get_components(
    f::Query8{A,B,C,D,E,F,G,H},
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
    return f[]
end

@inline function Base.getindex(
    f::Query8{A,B,C,D,E,F,G,H},
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
    a = f._storage_a.data[f._index]
    b = f._storage_b.data[f._index]
    c = f._storage_c.data[f._index]
    d = f._storage_d.data[f._index]
    e = f._storage_e.data[f._index]
    f = f._storage_f.data[f._index]
    g = f._storage_g.data[f._index]
    h = f._storage_h.data[f._index]
    return a, b, c, d, e, f, g, h
end

@inline function Base.iterate(f::Query8, state::Int)
    f._index = state
    while f._index <= length(f._world._archetypes)
        archetype = f._world._archetypes[f._index]
        if _contains_all(archetype.mask, f._mask)
            return f._index, f._index + 1
        end
        f._index += 1
    end
    f._index = 0
    return nothing
end

@inline function Base.iterate(f::Query8)
    f._index = 1
    return Base.iterate(f, f._index)
end
