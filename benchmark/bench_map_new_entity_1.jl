
function setup_map_new_entity_1(n::Int)
    world = World(Position, Velocity)
    map = Map(world, Val.((Position,)))

    # Run once to allocate memory
    entities = Vector{Entity}()
    for _ in 1:n
        e = new_entity!(map, (Position(0, 0),))
        push!(entities, e)
    end

    for e in entities
        remove_entity!(world, e)
    end

    return map
end

function benchmark_map_new_entity_1(args, n)
    map = args
    for _ in 1:n
        new_entity!(map, (Position(0, 0),))
    end
end

for n in (100, 10_000)
    SUITE["benchmark_map_new_entity_1 n=$n"] = @be setup_map_new_entity_1($n) benchmark_map_new_entity_1(_, $n) seconds = SECONDS
end
