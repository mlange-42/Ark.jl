
function setup_world_new_entities_1_def(n::Int)
    world = World(Position, Velocity)

    # Run once to allocate memory
    for (e, pos_col) in @new_entities!(world, n, (Position,))
        @inbounds for i in eachindex(e)
            pos_col[i] = Position(0, 0)
        end
    end

    return world
end

function benchmark_world_new_entities_1_def(args, n::Int)
    world = args
    new_entities!(world, n, (Position(0,0),); iterate=false)
    return world
end

for n in (100, 10_000)
    SUITE["benchmark_world_new_entities_1_def n=$n"] = @be setup_world_new_entities_1_def($n) benchmark_world_new_entities_1_def(_, $n) seconds = SECONDS
end
