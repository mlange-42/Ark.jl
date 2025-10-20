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

function Base.iterate(r::Filter2, state::Int)
    state <= 10 ? (state, state + 1) : nothing
end

function Base.iterate(f::Filter2)
    f._index = 1
    return Base.iterate(f, f._index)
end
