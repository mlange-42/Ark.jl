function setup_world_new_entities_5_def(n::Int)
    world = World(Position, Velocity, CompA, CompB, CompC)

    # Run once to allocate memory
    entities = Vector{Entity}()
    for (e, pos_col, vel_col, a_col, b_col, c_col) in @new_entities!(
        world, n, (Position, Velocity, CompA, CompB, CompC))
        append!(entities, e)
        @inbounds for i in eachindex(e)
            pos_col[i] = Position(0, 0)
            vel_col[i] = Velocity(0, 0)
            a_col[i] = CompA(0, 0)
            b_col[i] = CompB(0, 0)
            c_col[i] = CompC(0, 0)
        end
    end

    for e in entities
        remove_entity!(world, e)
    end

    return world
end

function benchmark_world_new_entities_5_def(args, n::Int)
    world = args
    new_entities!(world, n, (Position(0, 0), Velocity(0, 0), CompA(0, 0), CompB(0, 0), CompC(0, 0)); iterate = false)
end

for n in (100, 10_000)
    SUITE["benchmark_world_new_entities_5_def n=$n"] = @be setup_world_new_entities_5_def($n) benchmark_world_new_entities_5_def(_, $n) evals = 1 seconds = SECONDS
end
