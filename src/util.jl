
function _swap_remove!(v::AbstractArray, i::UInt32)::Bool
    last_index = length(v)
    swapped = i != last_index
    if swapped
        @inbounds v[i] = v[last_index]
    end
    pop!(v)
    return swapped
end

@inline function _to_types(::Type{TS}) where {TS<:Tuple}
    return [x.parameters[1] for x in TS.parameters]
end

const DEBUG = ("ARK_RUNNING_TESTS" in keys(ENV) && lowercase(ENV["ARK_RUNNING_TESTS"]) == "true")

macro check(arg)
    DEBUG ? esc(:(@assert $arg)) : nothing
end

function _format_type(T)
    if T isa Type && T <: Type
        return _format_type(T.parameters[1])
    elseif T isa DataType && isempty(T.parameters)
        return string(nameof(T))
    elseif T isa DataType
        return string(nameof(T), "{", join(map(_format_type, T.parameters), ", "), "}")
    else
        return string(T)
    end
end


function throw_if_add_remove_same_operation(add, remove)
    if !isempty(intersect(add, remove))
        throw(ArgumentError("component added and removed in the same exchange operation"))
    end
end

function throw_if_id_twice(add)
    if length(add) != length(unique(add))
        throw(ArgumentError("component added twice"))
    end
end