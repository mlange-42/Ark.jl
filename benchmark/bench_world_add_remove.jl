
println("-----------------------------------------------")
println("                World add/remove 1 of 2")
println("-----------------------------------------------")

function setup_world_add_remove(n_entities::Int)
    world = World(Position, Velocity)

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(world, (Position(i, i * 2),))
        push!(entities, e)
    end

    for e in entities
        add_components!(world, e, (Velocity(0, 0),))
        remove_components!(world, e, Val.((Velocity,)))
    end

    return (entities, world)
end

function benchmark_world_add_remove(n)
    bench = @benchmarkable begin
        for e in entities
            add_components!(world, e, (Velocity(0, 0),))
            remove_components!(world, e, Val.((Velocity,)))
        end
    end setup = ((entities, world) = setup_world_add_remove($n))

    tune!(bench)
    result = run(bench, seconds=seconds)
    print_result(result, n)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_world_add_remove(n)
end
