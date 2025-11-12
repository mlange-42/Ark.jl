struct MouseSystem <: System
end

function initialize!(s::MouseSystem, world::World)
    screen = get_resource(world, WorldScreen)
    add_resource!(world, Mouse(0, 0, false))

    function mouse_move(window::Ptr{Cvoid}, x::Cint, y::Cint)::Cvoid
        ptr = mfb_get_user_data(window)
        w = unsafe_pointer_to_objref(ptr)::World

        mouse = get_resource(w, Mouse)
        size = get_resource(w, WorldSize)
        scale = get_resource(w, Scale)

        sx, sy = x * scale.scale, y * scale.scale
        mouse.x = sx
        mouse.y = sy
        mouse.inside = contains(size, Float64(sx), Float64(sy))

        return nothing
    end

    mfb_set_mouse_move_callback(screen.screen, mouse_move)
end
