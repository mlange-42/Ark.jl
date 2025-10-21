
println("-----------------------------------------------")
println("                Map Pos/Vel")
println("-----------------------------------------------")

function setup_world(n_entities::Int)
    world = World()
    map1 = Map1{Position}(world)
    map2 = Map2{Position,Velocity}(world)

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map2, Position(i, i * 2), Velocity(1, 1))
        push!(entities, e)
    end

    return entities, map1, map2
end

function benchmark_iteration(n)
    bench = @benchmarkable begin
        for e in entities
            pos, vel = map2[e]
            map1[e] = Position(pos.x + vel.dx, pos.y + vel.dy)
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
