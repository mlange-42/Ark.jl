
function setup_world_update_1(n_entities::Int)
    world = World(Position, Velocity)
    map = Map(world, Val.((Position,)))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map, (Position(i, i * 2),))
        push!(entities, e)
    end

    for e in entities
        pos, = get_components(world, e, Val.((Position,)))
        p = pos[]
        pos[] = Position(p.x + 1, p.y)
    end

    return (entities, world)
end

function benchmark_world_update_1(args, n)
    entities, world = args
    for e in entities
        pos, = get_components(world, e, Val.((Position,)))
        p = pos[]
        pos[] = Position(p.x + 1, p.y)
    end
end

for n in (100, 10_000)
    SUITE["benchmark_world_update_1 n=$n"] = @be setup_world_update_1($n) benchmark_world_update_1(_, $n) seconds = SECONDS
end
