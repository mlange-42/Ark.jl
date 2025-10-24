
function setup_query_posvel_simd(n_entities::Int)
    world = World(Position, Velocity)

    for i in 1:n_entities
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
    end

    return world
end

function benchmark_query_posvel_simd(args, n)
    world = args
    for arch in @Query(world, (Position, Velocity))
        e, (x, y), (dx, dy) = unpack.(arch)
        for i in eachindex(e)
            @inbounds x[i] += dx[i]
            @inbounds y[i] += dy[i]
        end
    end
end

for n in (100, 1_000, 10_000, 100_000)
    SUITE["benchmark_query_posvel_simd n=$n"] = @be setup_query_posvel_simd($n) benchmark_query_posvel_simd(_, $n) seconds = SECONDS
end
