
const _vec_map_chunk_size = 16

struct _VecMap{T,M}
    map::Vector{Int}
    data::Vector{T}
end

function _VecMap{T,M}() where {T,M}
    _VecMap{T,M}(zeros(Int, 5), Vector{T}())
end

function _set_map!(m::_VecMap{T}, index::Int, value::T) where T
    prev_size = length(m.map)
    if prev_size < index
        size = (index + _vec_map_chunk_size) & -_vec_map_chunk_size
        resize!(m.map, size)
        @inbounds m.map[prev_size+1:size] .= 0
    end
    push!(m.data, value)
    @inbounds m.map[index] = length(m.data)
end

function _get_map(m::_VecMap, index::Int)
    @inbounds m.data[m.map[index]]
end

function _in_map(m::_VecMap, index::Int)
    index <= length(m.map) && @inbounds m.map[index] != 0
end
