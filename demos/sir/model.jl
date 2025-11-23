
using Ark
using Random
using Parameters

include("../_common/resources.jl")
include("resources.jl")
include("components.jl")
include("utils.jl")

new_world(N) = World(S, I, R; initial_capacity=N)

function initialize_world!(world::World, N::Int, I0::Int, beta::Float64, c::Float64, r::Float64, dt::Float64)
    add_resource!(world, Tick(0))
    add_resource!(world, Time(0.0))
    add_resource!(world, Terminate(false))
    add_resource!(world, Buffer(Entity[], Entity[], Float64[], Entity[]))
    add_resource!(world, Params(N, I0, beta, c, r, dt))

    new_entities!(world, N - I0, (S(),))
    new_entities!(world, I0, (I(),))

    return world
end

function step_world!(world::World)
    params = get_resource(world, Params)
    Parameters.@unpack N, I0, beta, c, r, dt = params

    # Update world time
    get_resource(world, Tick).tick += 1
    get_resource(world, Time).time += dt

    # Calculate probabilities
    i_count = get_count(world, I)
    foi = beta * c * i_count / N
    prob_infection = rate_to_probability(foi, dt)
    prob_recovery = rate_to_probability(r, dt)

    buffer = get_resource(world, Buffer)
    Parameters.@unpack s_to_i, i_to_r, rands, ents = buffer

    # S -> I Transition
    for (entities,) in Query(world, (), with=(S,))
        resize!(rands, length(entities))
        rand!(rands)
        @inbounds for k in eachindex(entities)
            if rands[k] <= prob_infection
                push!(s_to_i, entities[k])
            end
        end
    end

    # I -> R Transition
    for (entities,) in Query(world, (), with=(I,))
        resize!(rands, length(entities))
        rand!(rands)
        @inbounds for k in eachindex(entities)
            if rands[k] <= prob_recovery
                push!(i_to_r, entities[k])
            end
        end
    end

    # Apply Transitions
    for entity in s_to_i
        exchange_components!(world, entity, add=(I(),), remove=(S,))
    end
    for entity in i_to_r
        exchange_components!(world, entity, add=(R(),), remove=(I,))
    end

    # Cleanup buffers
    resize!(i_to_r, 0)
    resize!(s_to_i, 0)

    return world
end
