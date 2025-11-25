struct MouseSystem <: System
end

function initialize!(s::MouseSystem, world::World)
    window = get_resource(world, Window)
    size = get_resource(world, WorldSize)

    mouse = add_resource!(world, Mouse(0, 0, false))

    on(window.scene.events.mouseposition) do mp
        mouse.x = mp[1]
        mouse.y = mp[2]
        x, y = mp
        mouse.inside = contains(size, x, y)
    end
end
