
struct GrazerInit <: System
    count::Int
end

GrazerInit(;
    count::Int=100,
) = GrazerInit(count)

function initialize!(s::GrazerInit, world::World)
    size = get_resource(world, WorldSize)
    new_entities!(world, s.count,
        (Position, Rotation, Energy, Genes, Moving),
    ) do (_, positions, rotations, energies, genes, _)
        for i in eachindex(positions)
            positions[i] = Position(
                rand() * size.width - 0.01,
                rand() * size.height - 0.01,
            )
            rotations[i] = Rotation(rand() * 2 * π)
            energies[i] = Energy(rand() * 0.5 + 0.5)
            genes[i] = Genes(
                max_angle=rand(),
                reverse_prob=rand(),
                move_thresh=rand(),
                graze_thresh=rand(),
                num_offspring=rand(),
                energy_share=rand(),
            )
        end
    end
end
