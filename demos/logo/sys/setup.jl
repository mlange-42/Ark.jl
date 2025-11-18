struct SetupSystem <: System
end

function initialize!(s::SetupSystem, world::World)
    world_size = get_resource(world, WorldSize)
    image = get_resource(world, ArkLogo).image
    sy, sx = size(image)

    offset_x = div(world_size.width - sx, 2)
    offset_y = div(world_size.height - sy, 2)

    coords = Vector{Tuple{Int,Int}}()

    @inbounds for y in 1:sy
        for x in 1:sx
            if image[y, x].r > 0.5
                push!(coords, (x + offset_x, y + offset_y))
            end
        end
    end

    for (_, positions, velocities, targets) in new_entities!(world, length(coords), (Position, Velocity, Target))
        @inbounds for i in eachindex(positions, velocities, targets)
            x, y = coords[i]
            positions[i] = Position(rand(1:world_size.width), rand(1:world_size.height))
            velocities[i] = Velocity(0, 0)
            targets[i] = Target(x, y)
        end
    end
end
