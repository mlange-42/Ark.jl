const _vec_map_chunk_size = 16

struct _VecMap{M}
    data::Vector{Int}
    used::_MutableMask{M}
end

function _VecMap{M}() where {M}
    _VecMap{M}(zeros(Int, 5), _MutableMask{M}())
end

function _get_map(m::_VecMap, index::Int)
    if !_get_bit(m.used, index)
        return nothing
    end
    @inbounds return m.data[index]
end

function _set_map!(m::_VecMap, index::Int, value::Int)
    curr_len = length(m.data)
    if curr_len < index
        new_len = (index + _vec_map_chunk_size) & -_vec_map_chunk_size
        resize!(m.data, new_len)
        @inbounds m.data[curr_len + 1:new_len] .= 0
    end
    _set_bit!(m.used, index)
    @inbounds m.data[index] = value
end
