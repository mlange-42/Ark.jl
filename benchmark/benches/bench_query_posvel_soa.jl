
function setup_query_posvel_soa(n_entities::Int)
    world = World(PositionSoA, VelocitySoA)
    for i in 1:n_entities
        new_entity!(world, (PositionSoA(i, i * 2), VelocitySoA(1, 1)))
    end
    for columns in @Query(world, (PositionSoA, VelocitySoA))
        _, (x, y), (dx, dy) = components.(columns)
        @inbounds x .+= dx
        @inbounds y .+= dy
    end
    return world
end

function benchmark_query_posvel_soa(args, n)
    world = args
    for columns in @Query(world, (PositionSoA, VelocitySoA))
        _, (x, y), (dx, dy) = components.(columns)
        @inbounds x .+= dx
        @inbounds y .+= dy
    end
    return world
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_query_posvel_soa n=$(n)"] =
        @be setup_query_posvel_soa($n) benchmark_query_posvel_soa(_, $n) evals = 100 seconds = SECONDS
end
