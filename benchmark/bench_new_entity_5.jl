
function setup_new_entity_5(n::Int)
    world = World()
    map = Map(world, (Position, Velocity, CompA, CompB, CompC))

    # Run once to allocate memory
    entities = Vector{Entity}()
    for _ in 1:n
        e = new_entity!(map, (Position(0, 0), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)))
        push!(entities, e)
    end

    for e in entities
        remove_entity!(world, e)
    end

    return map
end

function benchmark_new_entity_5(args, n)
    map = args
    for _ in 1:n
        new_entity!(map, (Position(0, 0), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)))
    end
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_new_entity_5 n=$n"] = @benchmarkable setup_new_entity_5($n) benchmark_new_entity_5(_, $n)
end
