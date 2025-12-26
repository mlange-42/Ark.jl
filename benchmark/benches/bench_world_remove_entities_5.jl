
function setup_world_remove_entities_5(n::Int)
    world = World(Position, Velocity, CompA, CompB, CompC)

    # Run once to allocate memory
    new_entities!(world, n, (Position, Velocity, CompA, CompB, CompC)) do (e, pos_col, vel_col, a_col, b_col, c_col)
        @inbounds for i in eachindex(e)
            pos_col[i] = Position(0, 0)
            vel_col[i] = Velocity(0, 0)
            a_col[i] = CompA(0, 0)
            b_col[i] = CompB(0, 0)
            c_col[i] = CompC(0, 0)
        end
    end

    filter = Filter(world, (Position, Velocity, CompA, CompB, CompC))

    return (world, filter)
end

function benchmark_world_remove_entities_5(args, n::Int)
    world, filter = args
    remove_entities!(world, filter)
end

for n in (100, 10_000)
    SUITE["benchmark_world_remove_entities_5 n=$(n)"] =
        @be setup_world_remove_entities_5($n) benchmark_world_remove_entities_5(_, $n) evals = 1 seconds = SECONDS
end
