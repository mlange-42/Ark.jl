
function setup_query_posvel(n_entities::Int)
    world = World()
    map = Map(world, (Position, Velocity))

    for i in 1:n_entities
        new_entity!(map, (Position(i, i * 2), Velocity(1, 1)))
    end

    query = Query(world, (Position, Velocity))
    return query
end

function benchmark_query_posvel(args, n)
    query = args
    for _ in query
        pos_column, vel_column = query[]
        for i in eachindex(pos_column)
            @inbounds pos = pos_column[i]
            @inbounds vel = vel_column[i]
            @inbounds pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
        end
    end
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_query_posvel n=$n"] = @benchmarkable setup_query_posvel($n) benchmark_query_posvel(_, $n)
end
