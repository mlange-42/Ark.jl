
function setup_map_set_1(n_entities::Int)
    world = World(Position, Velocity)
    map = @Map(world, (Position,))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map, (Position(i, i * 2),))
        push!(entities, e)
    end

    for e in entities
        map[e] = (Position(1, 2),)
    end

    return (entities, map)
end

function benchmark_map_set_1(args)
    entities, map = args
    for e in entities
        map[e] = (Position(1, 2),)
    end
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_map_set_1 n=$n"] = @be setup_map_set_1($n) benchmark_map_set_1(_) seconds = SECONDS
end
