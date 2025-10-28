
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
        sum += pos[].x + vel[].dx + a[].x + b[].x + c[].x
    end
    sum

    return (entities, world)
end

function benchmark_world_get_5(args, n)
    entities, world = args
    sum = 0.0
    for e in entities
        pos, vel, a, b, c = get_components(world, e, Val.((Position, Velocity, CompA, CompB, CompC)))
        sum += pos[].x + vel[].dx + a[].x + b[].x + c[].x
    end
end

for n in (100, 10_000)
    SUITE["benchmark_world_get_5 n=$n"] = @be setup_world_get_5($n) benchmark_world_get_5(_, $n) seconds = SECONDS
end
