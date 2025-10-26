
function setup_world_new_entity_5(n::Int)
    world = World(Position, Velocity, CompA, CompB, CompC)

    # Run once to allocate memory
    entities = Vector{Entity}()
    for _ in 1:n
        e = new_entity!(world, (Position(0, 0), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)))
        push!(entities, e)
    end

    for e in entities
        remove_entity!(world, e)
    end

    return world
end

function benchmark_world_new_entity_5(args, n::Int)
    world = args
    for _ in 1:n
        new_entity!(world, (Position(0, 0), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)))
    end
end

for n in (100, 10_000)
    SUITE["benchmark_world_new_entity_5 n=$n"] = @be setup_world_new_entity_5($n) benchmark_world_new_entity_5(_, $n) seconds = SECONDS
end
