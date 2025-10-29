
function _swap_remove!(v::Vector, i::UInt32)::Bool
    last_index = length(v)
    swapped = i != last_index
    if swapped
        @inbounds v[i] = v[last_index]
    end
    pop!(v)
    return swapped
end

struct _Missing{C}
end

Base.getindex(::_Missing{C}, i::Integer) where C = error(error("entity has no $(string(C)) component"))
Base.setindex!(::_Missing{C}, ::C, ::Integer) where C = error(error("entity has no $(string(C)) component"))
Base.length(::_Missing{C}) where C = 0
Base.iterate(::_Missing{C}) where C = nothing
