
const _vec_map_chunk_size = 16

struct _VecMap{T,M,B}
    data::Vector{T}
    used::_MutableMask{M,B}
end

function _VecMap{T,M}() where {T,M}
    _VecMap(Vector{T}(undef, 5), _MutableMask{M}())
end

function _get_map(m::_VecMap, index::Int)
    if !_get_bit(m.used, index)
        return nothing
    end
    @inbounds return m.data[index]
end

function _set_map!(m::_VecMap{T}, index::Int, value::T) where T
    if length(m.data) < index
        size = (index + _vec_map_chunk_size) & -_vec_map_chunk_size
        resize!(m.data, size)
    end
    _set_bit!(m.used, index)
    @inbounds m.data[index] = value
end
