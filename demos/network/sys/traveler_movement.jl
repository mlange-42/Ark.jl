
struct TravelerMovement <: System
    speed::Float64
end

TravelerMovement(;
    speed::Float64=1.0,
) = TravelerMovement(speed)

function update!(s::TravelerMovement, world::World)
    for (_, travelers, positions) in Query(world, (Traveler, Position))
        travelers.position .+= s.speed
        for i in eachindex(travelers, positions)
            traveler = travelers[i]
            new_fwd = traveler.forward
            new_pos = traveler.position + s.speed

            edge_pos, edge_len = get_components(world, traveler.edge, (EdgePosition, EdgeLength))

            if traveler.position > edge_len.length
                new_fwd = !new_fwd
                new_pos = 0.0
            end

            travelers[i] = Traveler(traveler.edge, new_pos, new_fwd)
            positions[i] = position(new_pos, new_fwd, edge_pos, edge_len)
        end
    end
end
