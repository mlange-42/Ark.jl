
function _swap_remove!(v::Vector, i::UInt32)::Bool
    last_index = length(v)
    swapped = i != last_index
    if swapped
        @inbounds v[i] = v[last_index]
    end
    pop!(v)
    return swapped
end

function fill_range!(v::Vector, range::UnitRange{Int}, value)
    @inbounds @simd for i in range
        v[i] = value
    end
    return v
end
