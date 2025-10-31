
function setup_query_create(n)
    world = World(Position, Velocity)
    queries = Vector{Query}(undef, n)

    return world, queries
end

function benchmark_query_create(args, n)
    world, queries = args

    for i in 1:n
        queries[i] = @Query(world, (Position, Velocity))
    end
    return queries
end

SUITE["benchmark_query_create n=1000"] =
    @be setup_query_create($1000) benchmark_query_create(_, $1000) seconds = SECONDS
