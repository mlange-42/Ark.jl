
println("-----------------------------------------------")
println("                Add/remove 1 of 2")
println("-----------------------------------------------")

function setup_add_remove(n_entities::Int)
    world = World(Position, Velocity)
    map1 = Map(world, (Position,))
    map2 = Map(world, (Velocity,))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map1, (Position(i, i * 2),))
        push!(entities, e)
    end

    for e in entities
        add_components!(map2, e, (Velocity(0, 0),))
        remove_components!(map2, e)
    end

    return (entities, map2)
end

function benchmark_add_remove(n)
    bench = @benchmarkable begin
        for e in entities
            add_components!(map2, e, (Velocity(0, 0),))
            remove_components!(map2, e)
        end
    end setup = ((entities, map2) = setup_add_remove($n))

    tune!(bench)
    result = run(bench, seconds=seconds)
    print_result(result, n)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_add_remove(n)
end
