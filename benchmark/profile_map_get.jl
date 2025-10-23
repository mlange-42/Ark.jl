using Ark
using Printf
using Profile
using StatProfilerHTML

include("BenchTypes.jl")

function profile_add_remove()
    n = 100_000
    iter = 10000
    world = World(Position, Velocity)
    map1 = Map(world, Val.((Position,)))

    entities = Vector{Entity}()
    for i in 1:n
        e = new_entity!(map1, (Position(1, 1),))
        push!(entities, e)
    end

    sum = 0.0
    t = @elapsed for _ in 1:iter
        for e in entities
            pos, = map1[e]
            sum += pos.x
        end
    end
    println("elapsed time per entity (ns): ", t * 1e9 / (iter * n))
    if sum != iter * n
        error("wrong sum: ", sum)
    end
end

Profile.clear()
profile_add_remove()
@profilehtml profile_add_remove()
