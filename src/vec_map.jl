
const _vec_map_chunk_size = 16

struct _VecMap{T}
    data::Vector{T}
    used::_MutableMask
end

function _VecMap{T}() where T
    _VecMap{T}(Vector{T}(undef, 5), _MutableMask())
end

function _get_map(m::_VecMap{T}, index::UInt8)::Union{Nothing,T} where T
    if !_get_bit(m.used, index)
        return nothing
    end
    @inbounds return m.data[index]
end

function _set_map!(m::_VecMap{T}, index::UInt8, value::T) where T
    if length(m.data) < index
        size = div((index + _vec_map_chunk_size), _vec_map_chunk_size) * _vec_map_chunk_size
        resize!(m.data, size)
    end
    _set_bit!(m.used, index)
    @inbounds m.data[index] = value
end
