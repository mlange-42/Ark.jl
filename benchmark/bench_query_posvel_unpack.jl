
function setup_query_posvel_unpack(n_entities::Int)
    world = World(Position, Velocity)

    for i in 1:n_entities
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
    end

    return world
end

function benchmark_query_posvel_unpack(args, n)
    world = args
    for (ent, pos_column, vel_column) in @Query(world, (Position, Velocity))
        px = pos_column.x
        py = pos_column.y
        vx = vel_column.dx
        vy = vel_column.dy
        for i in eachindex(ent)
            @inbounds px[i] += vx[i]
            @inbounds py[i] += vy[i]
        end
    end
    return world
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_query_posvel_unpack n=$n"] = @be setup_query_posvel_unpack($n) benchmark_query_posvel_unpack(_, $n) seconds = SECONDS
end
