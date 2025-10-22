
println("-----------------------------------------------")
println("                World get 5")
println("-----------------------------------------------")

function setup_world_get_5(n_entities::Int)
    world = World(Position, Velocity, CompA, CompB, CompC)
    map = Map(world, Val.((Position, Velocity, CompA, CompB, CompC)))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map, (Position(i, i * 2), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)))
        push!(entities, e)
    end

    sum = 0.0
    for e in entities
        pos, vel, a, b, c = get_components(world, e, Val.((Position, Velocity, CompA, CompB, CompC)))
        sum += pos.x + vel.dx + a.x + b.x + c.x
    end
    sum

    return (entities, world)
end

function benchmark_world_get_5(n)
    bench = @benchmarkable begin
        sum = 0.0
        for e in entities
            pos, vel, a, b, c = get_components(world, e, Val.((Position, Velocity, CompA, CompB, CompC)))
            sum += pos.x + vel.dx + a.x + b.x + c.x
        end
        sum
    end setup = ((entities, world) = setup_world_get_5($n))

    tune!(bench)
    result = run(bench, seconds=seconds)
    print_result(result, n)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_world_get_5(n)
end
