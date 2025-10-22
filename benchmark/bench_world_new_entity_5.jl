
println("-----------------------------------------------")
println("                World new entity 5")
println("-----------------------------------------------")

function setup_world_new_entity_5(n::Int)
    world = World(Position, Velocity, CompA, CompB, CompC)

    # Run once to allocate memory
    entities = Vector{Entity}()
    for _ in 1:n
        e = new_entity!(world, (Position(0, 0), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)))
        push!(entities, e)
    end

    for e in entities
        remove_entity!(world, e)
    end

    return world
end

function benchmark_world_new_entity_5(n::Int)
    bench = @benchmarkable begin
        for _ in 1:$n
            new_entity!(world, (Position(0, 0), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)))
        end
    end setup = (world = setup_world_new_entity_5($n))

    tune!(bench)
    result = run(bench, seconds=seconds)
    print_result(result, n)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_world_new_entity_5(n)
end
