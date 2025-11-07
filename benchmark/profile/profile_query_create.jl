using Ark
using Printf
using Profile
using StatProfilerHTML

include("BenchTypes.jl")

function profile_query_create()
    iter = 100_000_000
    world = World(Position, Velocity)

    sum = 0
    for _ in 1:iter
        query = Query(world, Val.((Position, Velocity)))
        sum += query._lock
        close!(query)
    end

    sum
end

profile_query_create()
Profile.clear()
@profilehtml profile_query_create()
