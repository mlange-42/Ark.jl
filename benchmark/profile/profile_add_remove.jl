using Ark
using Printf
using Profile
using StatProfilerHTML

include("BenchTypes.jl")

function profile_add_remove()
    n = 10_000
    iter = 10_000
    world = World(Position, Velocity)

    entities = Vector{Entity}()
    for i in 1:n
        e = new_entity!(world, (Position(i, i * 2),))
        push!(entities, e)
    end

    for _ in 1:iter
        for e in entities
            add_components!(world, e, (Velocity(0, 0),))
            @remove_components!(world, e, (Velocity,))
        end
    end
end

profile_add_remove()
Profile.clear()
@profilehtml profile_add_remove()
