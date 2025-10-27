
function setup_world_new_entities_1(n::Int)
    world = World(Position, Velocity)

    # Run once to allocate memory
    for (e, pos_col) in new_entities!(world, n, (Position,); iterate=true)
        @inbounds for i in eachindex(e)
            pos_col[i] = Position(0, 0)
        end
    end

    return world
end

function benchmark_world_new_entities_1(args, n::Int)
    world = args
    for (e, pos_col) in new_entities!(world, n, (Position,); iterate=true)
        @inbounds for i in eachindex(e)
            pos_col[i] = Position(0, 0)
        end
    end
end

for n in (100, 10_000)
    SUITE["benchmark_world_new_entities_1 n=$n"] = @be setup_world_new_entities_1($n) benchmark_world_new_entities_1(_, $n) seconds = SECONDS
end
