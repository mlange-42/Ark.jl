
function setup_ark_32B(n_entities::Int)
    world = World(Position, Velocity)

    for i in 1:n_entities
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
    end

    for (_, pos_column, vel_column) in @Query(world, (Position, Velocity))
        @inbounds for i in eachindex(pos_column)
            pos = pos_column[i]
            vel = vel_column[i]
            pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
        end
    end

    return world
end

function benchmark_ark_32B(args, n)
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
    SUITE["benchmark_ark bytes=032 n=$(n)"] =
        @be setup_ark_32B($n) benchmark_ark_32B(_, $n) evals = 100 seconds = SECONDS
end

function setup_ark_64B(n_entities::Int)
    world = World(Position, Velocity, Comp{1}, Comp{2})

    for i in 1:n_entities
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1), Comp{1}(0, 0), Comp{2}(0, 0)))
    end

    for (_, pos_column, vel_column) in @Query(world, (Position, Velocity))
        @inbounds for i in eachindex(pos_column)
            pos = pos_column[i]
            vel = vel_column[i]
            pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
        end
    end

    return world
end

function benchmark_ark_64B(args, n)
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
    SUITE["benchmark_ark bytes=064 n=$(n)"] =
        @be setup_ark_64B($n) benchmark_ark_64B(_, $n) evals = 100 seconds = SECONDS
end

function setup_ark_128B(n_entities::Int)
    world = World(Position, Velocity, Comp{1}, Comp{2}, Comp{3}, Comp{4}, Comp{5}, Comp{6})

    for i in 1:n_entities
        new_entity!(
            world,
            (Position(i, i * 2), Velocity(1, 1), Comp{1}(0, 0), Comp{2}(0, 0),
                Comp{3}(0, 0), Comp{4}(0, 0), Comp{5}(0, 0), Comp{6}(0, 0)),
        )
    end

    for (_, pos_column, vel_column) in @Query(world, (Position, Velocity))
        @inbounds for i in eachindex(pos_column)
            pos = pos_column[i]
            vel = vel_column[i]
            pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
        end
    end

    return world
end

function benchmark_ark_128B(args, n)
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
    SUITE["benchmark_ark bytes=128 n=$(n)"] =
        @be setup_ark_128B($n) benchmark_ark_128B(_, $n) evals = 100 seconds = SECONDS
end
