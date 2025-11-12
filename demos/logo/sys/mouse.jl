struct MouseSystem <: System
end

function initialize!(s::MouseSystem, world::World)
    screen = get_resource(world, WorldScreen)
    add_resource!(world, Mouse(0, 0, false))

    function mouse_move(window::Ptr{Cvoid}, x::Cint, y::Cint)::Cvoid
        ptr = mfb_get_user_data(window)
        world_ref = unsafe_pointer_to_objref(ptr)::Ref{World}
        w = world_ref[]

        #mouse = get_resource(w, Mouse)
        #size = get_resource(w, WorldSize)
        # mouse.x = x
        # mouse.y = y
        # mouse.inside = contains(size, x, y)
        println(x, " ", y)
        return nothing
    end

    mfb_set_mouse_move_callback(screen.screen, mouse_move)
end
