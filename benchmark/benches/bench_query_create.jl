
function setup_query_create(n)
    world = World(Position, Velocity)

    query = @Query(world, (Position, Velocity))
    queries = Vector{typeof(query)}(undef, n)
    close!(query)

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
