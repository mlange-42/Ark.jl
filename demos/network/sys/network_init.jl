
struct NetworkInit <: System
    distance::Int
end

NetworkInit(;
    distance::Int=25,
) = NetworkInit(distance)

function initialize!(s::NetworkInit, world::World)
    size = get_resource(world, WorldSize)

    rows = div(size.height, s.distance)
    cols = div(size.width, s.distance)
    offset_x = (size.width - (cols - 1) * s.distance) / 2
    offset_y = (size.height - (rows - 1) * s.distance) / 2
    jitter = s.distance / 4

    for (_, positions) in new_entities!(world, rows * cols, (Position,))
        for i in eachindex(positions)
            col = (i - 1) % cols
            row = div((i - 1), cols)
            positions[i] = Position(
                col * s.distance + offset_x + (rand() * 2 - 1) * jitter,
                row * s.distance + offset_y + (rand() * 2 - 1) * jitter,
            )
        end
    end
end
