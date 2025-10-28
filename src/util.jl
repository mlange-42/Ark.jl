
function _swap_remove!(v::Vector, i::UInt32)::Bool
    last_index = length(v)
    swapped = i != last_index
    if swapped
        @inbounds v[i] = v[last_index]
    end
    pop!(v)
    return swapped
end

Base.@propagate_inbounds function Base.getindex(a::SubArray, i::Integer)
    Base.getindex(a, 1)
end
Base.@propagate_inbounds function Base.setindex!(a::SubArray, value, i::Integer)
    Base.setindex!(a, value, 1)
end
