struct MouseSystem <: System
end

function initialize!(s::MouseSystem, world::World)
    scene = get_resource(world, WorldScene)
    size = get_resource(world, WorldSize)

    mouse = add_resource!(world, Mouse((0, 0), false))

    on(scene.scene.events.mouseposition) do mp
        mouse.position = mp
        x, y = mp
        mouse.inside = contains(size, x, y)
    end
end
