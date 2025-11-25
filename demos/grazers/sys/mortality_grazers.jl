
struct MortalityGrazers <: System
    to_remove::Vector{Entity}
end

MortalityGrazers() = MortalityGrazers(Vector{Entity}())

function update!(s::MortalityGrazers, world::World)
    resize!(s.to_remove, 0)

    for (entities, energies) in Query(world, (Energy,))
        for i in eachindex(entities, energies)
            if energies[i].value <= 0
                push!(s.to_remove, entities[i])
            end
        end
    end

    for e in s.to_remove
        remove_entity!(world, e)
    end
end
