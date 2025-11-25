
struct InitGrazers <: System
    count::Int
end

InitGrazers(;
    count::Int=100,
) = InitGrazers(count)

function initialize!(s::InitGrazers, world::World)
    size = get_resource(world, WorldSize)
    for (_, positions, rotations, genes, _) in new_entities!(world, s.count, (Position, Rotation, Genes, Moving))
        for i in eachindex(positions)
            positions[i] = Position(
                rand() * size.width,
                rand() * size.height,
            )
            rotations[i] = Rotation(rand() * 2 * π)
            genes[i] = Genes(max_angle=rand() * 0.25 * π)
        end
    end
end
