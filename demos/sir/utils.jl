
function rate_to_probability(r::T, t::T) where {T<:AbstractFloat}
    1 - exp(-r * t)
end

function get_count(world, ::Type{T}) where {T<:HealthState}
    return count_entities(Query(world, (), with=(T,)))
end
