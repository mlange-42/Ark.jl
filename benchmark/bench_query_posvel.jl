
println("-----------------------------------------------")
println("              Query Pos/Vel")
println("-----------------------------------------------")

function setup_world(n_entities::Int)
    world = World()
    map = Map2{Position,Velocity}(world)

    for i in 1:n_entities
        new_entity!(map, Position(i, i * 2), Velocity(1, 1))
    end

    query = Query2{Position,Velocity}(world)
    return query
end

function benchmark_iteration(n)
    bench = @benchmarkable begin
        for _ in query
            pos_column, vel_column = query[]
            @inbounds for i in eachindex(pos_column)
                pos = pos_column[i]
                vel = vel_column[i]
                pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
            end
        end
    end setup = (query = setup_world($n))

    println("\nBenchmarking with $n entities...")
    tune!(bench)
    result = run(bench, seconds=10)
    println("Mean time per entity: $(time(mean(result)) / n) ns")
    display(result)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_iteration(n)
end
