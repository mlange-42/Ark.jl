
mutable struct RenderSystem <: System
end

function initialize!(s::RenderSystem, world::World)
    size = get_resource(world, WorldSize)

    window = mfb_open("Logo demo", size.width, size.height)
    mfb_set_target_fps(60)

    add_resource!(world, WorldScreen(window))
    add_resource!(world, Scale(
        size.width / mfb_get_window_width(window),
    ))

    image = zeros(UInt32, size.width, size.height)
    add_resource!(world, WorldImage(image))
end

function update!(s::RenderSystem, world::World)
    size = get_resource(world, WorldSize)

    data = get_resource(world, WorldImage).image
    fill!(data, 0)
    for (_, positions) in @Query(world, (Position,))
        @inbounds for i in eachindex(positions)
            pos = positions[i]
            if !contains(size, pos.x, pos.y)
                continue
            end
            data[round(Int, pos.x), round(Int, pos.y)] = 0xFFFFFFFF
        end
    end
end
