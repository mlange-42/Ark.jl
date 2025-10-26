
function setup_map_set_5(n_entities::Int)
    world = World(Position, Velocity, CompA, CompB, CompC)
    map = Map(world, Val.((Position, Velocity, CompA, CompB, CompC)))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map, (Position(i, i * 2), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)))
        push!(entities, e)
    end

    for e in entities
        map[e] = (Position(1, 2), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0))
    end

    return (entities, map)
end

function benchmark_map_set_5(args)
    entities, map = args
    for e in entities
        map[e] = (Position(1, 2), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0))
    end

end

for n in (100, 10_000)
    SUITE["benchmark_map_set_5 n=$n"] = @be setup_map_set_5($n) benchmark_map_set_5(_) seconds = SECONDS
end
