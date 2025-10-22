using Ark
using Printf
using Profile
using StatProfilerHTML

include("BenchTypes.jl")

function profile_add_remove()
    n = 10_000
    iter = 100
    world = World(Position, Velocity)
    map1 = Map(world, (Position,))
    map2 = Map(world, (Velocity,))

    entities = Vector{Entity}()
    for i in 1:n
        e = new_entity!(map1, (Position(i, i * 2),))
        push!(entities, e)
    end

    for _ in 1:iter
        for e in entities
            add_components!(map2, e, (Velocity(0, 0),))
            remove_components!(map2, e)
        end
    end
end

Profile.clear()
profile_add_remove()
@profilehtml profile_add_remove()
#ProfileView.view()
