
function test_query()
    world = World(Position, Velocity, Altitude, Health, ChildOf)

    new_entities!(world, 10, (Position(0, 0), Velocity(1, 1)))

    for _ in 1:100
        for (_, positions, velocities) in Query(world, (Position, Velocity))
            for i in eachindex(positions, velocities)
                pos = positions[i]
                vel = velocities[i]
                positions[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
            end
        end
    end
end
