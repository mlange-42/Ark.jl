
println("-----------------------------------------------")
println("                World get 1")
println("-----------------------------------------------")

function setup_world_get_1(n_entities::Int)
    world = World(Position, Velocity)
    map = Map(world, (Position,))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map, (Position(i, i * 2),))
        push!(entities, e)
    end

    sum = 0.0
    for e in entities
        pos, = get_components(world, e, Position)
        sum += pos.x
    end
    sum

    return (entities, world)
end

function benchmark_world_get_1(n)
    bench = @benchmarkable begin
        sum = 0.0
        for e in entities
            pos, = get_components(world, e, Position)
            sum += pos.x
        end
        sum
    end setup = ((entities, world) = setup_world_get_1($n))

    tune!(bench)
    result = run(bench, seconds=seconds)
    print_result(result, n)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_world_get_1(n)
end
