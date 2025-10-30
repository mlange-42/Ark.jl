
function setup_ark(n_entities::Int)
    world = World(Position, Velocity)

    for i in 1:n_entities
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
    end

    return world
end

function benchmark_ark(args, n)
    world = args
    for (_, pos_column, vel_column) in @Query(world, (Position, Velocity))
        @inbounds for i in eachindex(pos_column)
            pos = pos_column[i]
            vel = vel_column[i]
            pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
        end
    end
    return world
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_ark n=$n"] = @be setup_ark($n) benchmark_ark(_, $n) seconds = SECONDS
end
