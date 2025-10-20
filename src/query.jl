"""
    Filter2{A,B}

A filter for 2 components.
"""
mutable struct Filter2{A,B}
    _index::Int
    _world::World
    _ids::Tuple{UInt8,UInt8}
    _mask::_Mask
    _storage_a::_ComponentStorage{A}
    _storage_b::_ComponentStorage{B}
end

"""
    Filter2{A,B}(world::World)

Creates a filter for 2 components.
"""
function Filter2{A,B}(world::World) where {A,B}
    ids = (
        _component_id!(world, A),
        _component_id!(world, B),
    )
    return Filter2{A,B}(
        0,
        world,
        ids,
        _Mask(ids...),
        _get_storage(world, ids[1], A),
        _get_storage(world, ids[2], B),
    )
end

@inline function get_components(f::Filter2{A,B})::Tuple{Vector{A},Vector{B}} where {A,B}
    a = f._storage_a.data[f._index]
    b = f._storage_b.data[f._index]
    return a, b
end

@inline function Base.iterate(f::Filter2, state::Int)
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

@inline function Base.iterate(f::Filter2)
    f._index = 1
    return Base.iterate(f, f._index)
end
