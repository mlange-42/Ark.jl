
function setup_query_create(n)
    world = World(Position, Velocity)
    queries = Vector{Query}(undef, n)

    for i in 1:n
        query = @Query(world, (Position, Velocity))
        close!(query)
        queries[i] = query
    end

    return world, queries
end

function benchmark_query_create(args, n)
    world, queries = args

    for i in 1:n
        query = @Query(world, (Position, Velocity))
        close!(query)
        queries[i] = query
    end

    return queries
end

SUITE["benchmark_query_create n=1000"] =
    @be setup_query_create($1000) benchmark_query_create(_, $1000) seconds = SECONDS
