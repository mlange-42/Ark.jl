
function setup_map_add_remove(n_entities::Int)
    world = World(Position, Velocity)
    map1 = Map(world, Val.((Position,)))
    map2 = Map(world, Val.((Velocity,)))

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

function benchmark_add_remove(args, n)
    entities, map2 = args
    for e in entities
        add_components!(map2, e, (Velocity(0, 0),))
        remove_components!(map2, e)
    end
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_add_remove $n"] = @benchmarkable setup_add_remove($n) benchmark_add_remove(_, $n)
end
