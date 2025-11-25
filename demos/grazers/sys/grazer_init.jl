
struct GrazerInit <: System
    count::Int
end

GrazerInit(;
    count::Int=100,
) = GrazerInit(count)

function initialize!(s::GrazerInit, world::World)
    size = get_resource(world, WorldSize)
    for (_, positions, rotations, energies, genes, _) in new_entities!(world, s.count,
        (Position, Rotation, Energy, Genes, Moving))
        for i in eachindex(positions)
            positions[i] = Position(
                rand() * size.width,
                rand() * size.height,
            )
            rotations[i] = Rotation(rand() * 2 * π)
            energies[i] = Energy(rand() * 0.5 + 0.5)
            genes[i] = Genes(
                max_angle=rand() * 0.25 * π,
                move_thresh=rand(),
                graze_thresh=rand(),
            )
        end
    end
end
