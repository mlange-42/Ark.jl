
function _swap_remove!(v::Vector, i::UInt32)::Bool
    last_index = length(v)
    swapped = i != last_index
    if swapped
        @inbounds v[i] = v[last_index]
    end
    pop!(v)
    return swapped
end

const DEBUG = ("ARK_RUNNING_TESTS" in keys(ENV) && ENV["ARK_RUNNING_TESTS"])

macro check(arg)
    DEBUG ? esc(:(@assert $arg)) : nothing
end
