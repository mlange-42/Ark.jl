
function setup_map_posvel(n_entities::Int)
    world = World(Position, Velocity)
    map1 = Map(world, Val.((Position,)))
    map2 = Map(world, Val.((Position, Velocity)))

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(map2, (Position(i, i * 2), Velocity(1, 1)))
        push!(entities, e)
    end

    @inbounds for e in entities
        pos, vel = map2[e]
        p = pos[]
        v = vel[]
        pos[] = Position(p.x + v.dx, p.y + v.dy)
    end

    return (entities, map1, map2)
end

function benchmark_map_posvel(args)
    entities, map1, map2 = args
    @inbounds for e in entities
        pos, vel = map2[e]
        p = pos[]
        v = vel[]
        pos[] = Position(p.x + v.dx, p.y + v.dy)
    end
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_map_posvel n=$n"] = @be setup_map_posvel($n) benchmark_map_posvel(_) seconds = SECONDS
end
