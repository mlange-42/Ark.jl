
struct BoidsMovement <: System
end

function update!(s::BoidsMovement, world::World)
    for (_, positions, velocities) in Query(world, (Position, Velocity))
        for i in eachindex(positions, velocities)
            pos = positions[i].p
            vel = velocities[i].v
            positions[i] = Position((pos[1] + vel[1], pos[2] + vel[2]))
        end
    end

    for (_, velocities, rotations) in Query(world, (Velocity, Rotation))
        rotations.r .= direction_to_rotation.(velocities.v)
    end
end
