
function rate_to_probability(r::T, t::T) where {T<:AbstractFloat}
    1 - exp(-r * t)
end

function get_count(world, ::Type{T}) where {T<:HealthState}
    count = 0
    for (entities, ) in Query(world, (), with=(T, ))
        count += length(entities)
    end
    return count
end