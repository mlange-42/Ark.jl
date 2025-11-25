
struct BoidsInit <: System
    count::Int
end

BoidsInit(;
    count::Int=100,
) = BoidsInit(count)

function initialize!(s::BoidsInit, world::World)
    size = get_resource(world, WorldSize)

    for (_, positions, velocities, rotations) in new_entities!(world, s.count, (Position, Velocity, Rotation))
        for i in eachindex(positions, rotations)
            positions[i] = Position(Point2f(rand() * size.width, rand() * size.height))

            ang = rand() * 2 * π
            rotations[i] = Rotation(ang)
            velocities[i] = Velocity(rotation_to_direction(ang, 0.1))
        end
    end
end
