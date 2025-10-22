
function setup_map_get_5(n_entities::Int)
    world = World(Position, Velocity, CompA, CompB, CompC)
    map = Map(world, (Position, Velocity, CompA, CompB, CompC))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map, (Position(i, i * 2), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)))
        push!(entities, e)
    end

    sum = 0.0
    for e in entities
        pos, vel, a, b, c = map[e]
        sum += pos.x + vel.dx + a.x + b.x + c.x
    end
    sum

    return (entities, map)
end

function benchmark_map_get_5(args)
    entities, map = args
    sum = 0.0
    for e in entities
        pos, vel, a, b, c = map[e]
        sum += pos.x + vel.dx + a.x + b.x + c.x
    end
    return sum
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_map_get_5 n=$n"] = @benchmarkable setup_map_get_5($n) benchmark_map_get_5(_)
end
