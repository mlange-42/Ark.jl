
println("-----------------------------------------------")
println("                Map get 1")
println("-----------------------------------------------")

function setup_world(n_entities::Int)
    world = World()
    map = Map(world, (Position,))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map, (Position(i, i * 2),))
        push!(entities, e)
    end

    return (entities, map)
end

function benchmark_iteration(n)
    bench = @benchmarkable begin
        sum = 0.0
        for e in entities
            pos, = map[e]
            sum += pos.x
        end
    end setup = ((entities, map) = setup_world($n))

    tune!(bench)
    result = run(bench, seconds=seconds)
    print_result(result, n)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_iteration(n)
end
