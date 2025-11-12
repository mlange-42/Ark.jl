
function setup_world_posvel(n_entities::Int)
    world = World(Position, Velocity)

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
        push!(entities, e)
    end

    for e in entities
        pos, vel = get_components(world, e, Val.((Position, Velocity)))
        set_components!(world, e, (Position(pos.x + vel.dx, pos.y + vel.dy),))
    end

    return (entities, world)
end

function benchmark_world_posvel(args, n)
    entities, world = args
    for e in entities
        pos, vel = get_components(world, e, Val.((Position, Velocity)))
        set_components!(world, e, (Position(pos.x + vel.dx, pos.y + vel.dy),))
    end
end

function setup_world_posvel_access(n_entities::Int)
    world = World(Position, Velocity)

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
        push!(entities, e)
    end

    for e in entities
        pos_acc, vel_acc = access_components(world, e, Val.((Position, Velocity)))
        pos = pos_acc[]
        vel = vel_acc[]
        pos_acc[] = Position(pos.x + vel.dx, pos.y + vel.dy)
    end

    return (entities, world)
end

function benchmark_world_posvel_access(args, n)
    entities, world = args
    for e in entities
        pos_acc, vel_acc = access_components(world, e, Val.((Position, Velocity)))
        pos = pos_acc[]
        vel = vel_acc[]
        pos_acc[] = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_world_posvel n=$(n)"] =
        @be setup_world_posvel($n) benchmark_world_posvel(_, n) evals = 100 seconds = SECONDS
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_world_posvel_access n=$(n)"] =
        @be setup_world_posvel_access($n) benchmark_world_posvel_access(_, n) evals = 100 seconds = SECONDS
end
