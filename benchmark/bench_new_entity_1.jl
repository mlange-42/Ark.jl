
println("-----------------------------------------------")
println("                New entity 1")
println("-----------------------------------------------")

function setup_world(n::Int)
    world = World()
    map = Map(world, (Position,))

    # Run once to allocate memory
    entities = Vector{Entity}()
    for _ in 1:n
        e = new_entity!(map, (Position(0, 0),))
        push!(entities, e)
    end

    for e in entities
        remove_entity!(world, e)
    end

    return map
end

function benchmark_iteration(n::Int)
    bench = @benchmarkable begin
        for _ in 1:$n
            new_entity!(map, (Position(0, 0),))
        end
    end setup = (map = setup_world($n))

    tune!(bench)
    result = run(bench, seconds=seconds)
    print_result(result, n)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_iteration(n)
end
