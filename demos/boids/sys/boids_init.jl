
struct BoidsInit <: System
    count::Int
end

BoidsInit(;
    count::Int=100,
) = BoidsInit(count)

function initialize!(s::BoidsInit, world::World)
    size = get_resource(world, WorldSize)

    for (_, positions, rotations) in new_entities!(world, s.count, (Position, Rotation))
        for i in eachindex(positions, rotations)
            positions[i] = Position(rand() * size.width, rand() * size.height)
            rotations[i] = Rotation(rand() * 2 * π)
        end
    end
end
