
function _swap_remove!(v::AbstractVector{T}, i::UInt32)::Bool where T
    last_index = length(v)
    swapped = i != last_index
    if swapped
        @inbounds v[i] = v[last_index]
    end
    pop!(v)
    return swapped
end
