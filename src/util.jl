
function _swap_remove!(v::Vector, i::UInt32)::Bool
    last_index = length(v)
    swapped = i != last_index
    if swapped
        @inbounds v[i] = v[last_index]
    end
    pop!(v)
    return swapped
end

@inline function _try_to_types(::Type{TS}) where {TS<:Tuple}
    if !all(x -> x <: Val, TS.parameters)
        error(
            lazy"expected a tuple of Val types like Val.((Position, Velocity)), got $TS. " *
            "Consider using the related macro instead.",
        )
    end
    return [x.parameters[1] for x in TS.parameters]
end

const DEBUG = ("ARK_RUNNING_TESTS" in keys(ENV) && lowercase(ENV["ARK_RUNNING_TESTS"]) == "true")

macro check(arg)
    DEBUG ? esc(:(@assert $arg)) : nothing
end
