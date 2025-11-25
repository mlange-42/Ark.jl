
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
            max_angle = genes[i].max_angle * 0.5 * π

            r = (r + (rand() * 2 - 1) * max_angle + 2 * π) % (2 * π)
            positions[i] = Position(
                (p[1] + s.speed * cos(r) + size.width) % size.width,
                (p[2] + s.speed * sin(r) + size.height) % size.height,
            )
            rotations[i] = r
        end
    end
end
