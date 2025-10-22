
println("-----------------------------------------------")
println("                World Pos/Vel")
println("-----------------------------------------------")

function setup_world_posvel(n_entities::Int)
    world = World(Position, Velocity)
    map1 = Map(world, (Position,))
    map2 = Map(world, (Position, Velocity))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map2, (Position(i, i * 2), Velocity(1, 1)))
        push!(entities, e)
    end

    for e in entities
        pos, vel = get_components(world, e, Val.((Position, Velocity)))
        set_components!(world, e, (Position(pos.x + vel.dx, pos.y + vel.dy)))
    end

    return (entities, world)
end

function benchmark_world_posvel(n)
    bench = @benchmarkable begin
        for e in entities
            pos, vel = get_components(world, e, Val.((Position, Velocity)))
            set_components!(world, e, (Position(pos.x + vel.dx, pos.y + vel.dy),))
        end
    end setup = ((entities, world) = setup_world_posvel($n))

    tune!(bench)
    result = run(bench, seconds=seconds)
    print_result(result, n)
end

for n in (100, 1_000, 10_000, 100_000)
    benchmark_world_posvel(n)
end
