
struct Reproduction
    mother::Entity
    father::Entity
    offspring::Int
    energy::Float64
end

struct GrazerReproduction <: System
    max_offspring::Int
    cross_rate::Float64
    mutation_rate::Float64
    to_reproduce::Vector{Reproduction}
    mates::Vector{Entity}
end

GrazerReproduction(; max_offspring::Int, cross_rate::Float64, mutation_rate::Float64) =
    GrazerReproduction(max_offspring, cross_rate, mutation_rate, Vector{Reproduction}(), Vector{Entity}())

function update!(s::GrazerReproduction, world::World)
    resize!(s.to_reproduce, 0)
    resize!(s.mates, 0)

    for (entities,) in Query(world, (); with=(Energy,))
        append!(s.mates, entities)
    end

    for (entities, energies, genes) in Query(world, (Energy, Genes))
        for i in eachindex(entities, energies)
            if energies[i].value >= 1
                gene = genes[i]
                push!(
                    s.to_reproduce,
                    Reproduction(
                        entities[i],
                        rand(s.mates),
                        round(Int, s.max_offspring * gene.num_offspring),
                        gene.energy_share,
                    ),
                )
                energies[i] = Energy(1.0 - gene.energy_share)
            end
        end
    end

    for rep in s.to_reproduce
        energy = rep.energy / rep.offspring
        m, = get_components(world, rep.mother, (Genes,))
        f, = get_components(world, rep.father, (Genes,))
        for _ in 1:rep.offspring
            child = copy_entity!(world, rep.mother)
            genes = Genes(
                max_angle=mutate(m.max_angle, f.max_angle, s.cross_rate, s.mutation_rate),
                reverse_prob=mutate(m.reverse_prob, f.reverse_prob, s.cross_rate, s.mutation_rate),
                move_thresh=mutate(m.move_thresh, f.move_thresh, s.cross_rate, s.mutation_rate),
                graze_thresh=mutate(m.graze_thresh, f.graze_thresh, s.cross_rate, s.mutation_rate),
                num_offspring=mutate(m.num_offspring, f.num_offspring, s.cross_rate, s.mutation_rate),
                energy_share=mutate(m.energy_share, f.energy_share, s.cross_rate, s.mutation_rate),
            )
            set_components!(world, child, (
                Energy(energy),
                Rotation(rand() * 2 * π),
                genes,
            ))
        end
    end
end

function mutate(a::Float64, b::Float64, cross::Float64, rate::Float64)
    base = rand() < cross ? b : a
    return clamp(base + randn() * rate, 0, 1)
end
