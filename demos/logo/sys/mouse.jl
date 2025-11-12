struct MouseSystem <: System
end

function initialize!(s::MouseSystem, world::World)
    add_resource!(world, Mouse(0, 0, false))
end

function update!(s::MouseSystem, world::World)
    screen = get_resource(world, WorldScreen)
    mouse = get_resource(world, Mouse)
    size = get_resource(world, WorldSize)
    scale = get_resource(world, Scale)

    mouse.x = mfb_get_mouse_x(screen.screen) * scale.scale
    mouse.y = mfb_get_mouse_y(screen.screen) * scale.scale

    # TODO: this is currently useless, as coords are always inside the window
    mouse.inside = contains(size, mouse.x, mouse.y)
end
