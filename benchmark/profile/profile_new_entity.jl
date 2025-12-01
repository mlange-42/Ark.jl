using Ark
using Printf
using Profile
using StatProfilerHTML

include("BenchTypes.jl")

function setup_new_entity()
    n_entities = 100_000

    world = World(
        Position, Velocity,
    )

    entities = Entity[]

    for _ in 1:n_entities
        e = new_entity!(world, (Position(0, 0),))
    end

    for e in entities
        remove_entity!(world, e)
    end

    return world
end

function run_new_entity(world::World)
    n_entities = 100_000
    iters = 10_000

    for _ in 1:iters
        reset!(world)
        for _ in 1:n_entities
            e = new_entity!(world, (Position(0, 0),))
        end
    end

    return world
end

function profile_new_entity()
    world = setup_new_entity()
    run_new_entity(world)
end

Profile.clear()
profile_new_entity()
@profilehtml profile_new_entity()
