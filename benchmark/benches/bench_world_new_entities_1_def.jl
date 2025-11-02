
function setup_world_new_entities_1_def(n::Int)
    world = World(Position, Velocity)

    # Run once to allocate memory
    entities = Vector{Entity}()
    for (e, pos_col) in @add_entities!(world, n, (Position,))
        append!(entities, e)
        @inbounds for i in eachindex(e)
            pos_col[i] = Position(0, 0)
        end
    end

    for e in entities
        remove_entity!(world, e)
    end

    return world
end

function benchmark_world_new_entities_1_def(args, n::Int)
    world = args
    add_entities!(world, n, (Position(0, 0),); iterate=false)
    return world
end

for n in (100, 10_000)
    SUITE["benchmark_world_new_entities_1_def n=$n"] =
        @be setup_world_new_entities_1_def($n) benchmark_world_new_entities_1_def(_, $n) evals = 1 seconds = SECONDS
end
