
println("-----------------------------------------------")
println("              Query Pos/Vel")
println("-----------------------------------------------")

function setup_query_posvel(n_entities::Int)
    world = World(Position, Velocity)
    map = Map(world, (Position, Velocity))

    for i in 1:n_entities
        new_entity!(map, (Position(i, i * 2), Velocity(1, 1)))
    end

    query = Query(world, (Position, Velocity))

    for _ in query
        _, pos_column, vel_column = query[]
        for i in eachindex(pos_column)
            @inbounds pos = pos_column[i]
            @inbounds vel = vel_column[i]
            @inbounds pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
        end
    end

    return query
end

function benchmark_query_posvel(n)
    bench = @benchmarkable begin
        for _ in query
            pos_column, vel_column = query[]
            for i in eachindex(pos_column)
                @inbounds pos = pos_column[i]
                @inbounds vel = vel_column[i]
                @inbounds pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
            end
        end
    end setup = (query = setup_query_posvel($n))

    tune!(bench)
    result = run(bench, seconds=seconds)
    print_result(result, n)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_query_posvel(n)
end
