
function _swap_remove!(v::Vector, i::UInt32)::Bool
    last_index = length(v)
    swapped = i != last_index
    if swapped
        v[i] = v[last_index]
    end
    pop!(v)
    return swapped
end

function _swap_remove!(v::StructArray, i::UInt32)::Bool
    last_index = length(v)
    swapped = i != last_index
    if swapped
        v[i] = v[last_index]
    end
    pop!(v)
    return swapped
end
