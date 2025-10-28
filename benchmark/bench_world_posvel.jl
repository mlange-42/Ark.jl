
function setup_world_posvel(n_entities::Int)
    world = World(Position, Velocity)
    map1 = Map(world, Val.((Position,)))
    map2 = Map(world, Val.((Position, Velocity)))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map2, (Position(i, i * 2), Velocity(1, 1)))
        push!(entities, e)
    end

    for e in entities
        pos, vel = get_components(world, e, Val.((Position, Velocity)))
        p = pos[]
        v = vel[]
        pos[] = Position(p.x + v.dx, p.y + v.dy)
    end

    return (entities, world)
end

function benchmark_world_posvel(args, n)
    entities, world = args
    for e in entities
        pos, vel = get_components(world, e, Val.((Position, Velocity)))
        p = pos[]
        v = vel[]
        pos[] = Position(p.x + v.dx, p.y + v.dy)
    end
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_world_posvel n=$n"] = @be setup_world_posvel($n) benchmark_world_posvel(_, n) seconds = SECONDS
end
