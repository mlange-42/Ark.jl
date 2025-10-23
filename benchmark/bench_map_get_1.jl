
function setup_map_get_1(n_entities::Int)
    world = World(Position, Velocity)
    map = @Map(world, (Position,))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map, (Position(i, i * 2),))
        push!(entities, e)
    end

    sum = 0.0
    for e in entities
        pos, = map[e]
        sum += pos.x
    end
    sum

    return (entities, map)
end

function benchmark_map_get_1(args)
    entities, map = args
    sum = 0.0
    for e in entities
        pos, = map[e]
        sum += pos.x
    end
    return sum
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_map_get_1 n=$n"] = @be setup_map_get_1($n) benchmark_map_get_1(_)
end
