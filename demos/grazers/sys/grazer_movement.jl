
struct GrazerMovement <: System
    speed::Float64
end

GrazerMovement(;
    speed::Float64=0.1,
) = GrazerMovement(speed)

function update!(s::GrazerMovement, world::World)
    size = get_resource(world, WorldSize)
    for (_, positions, rotations, genes) in Query(world, (Position, Rotation, Genes); with=(Moving,))
        for i in eachindex(positions, rotations)
            r = rotations[i]
            p = positions[i]
            g = genes[i]
            max_angle = g.max_angle * 0.5 * π

            r = (r + (rand() * 2 - 1) * max_angle + 2 * π) % (2 * π)
            if rand() * 10 < g.reverse_prob
                r = (r + π + 2 * π) % (2 * π)
            end
            positions[i] = Position(
                (p[1] + s.speed * cos(r) + size.width) % (size.width - 0.001),
                (p[2] + s.speed * sin(r) + size.height) % (size.height - 0.001),
            )
            rotations[i] = r
        end
    end
end
