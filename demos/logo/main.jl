using GLMakie

include("scheduler.jl")
include("resources.jl")
include("sys/render.jl")

function main()
    GLMakie.activate!(renderloop=GLMakie.renderloop)

    size = WorldSize(800, 600)
    screen = GLMakie.Screen(framerate=60.0, vsync=true, render_on_demand=false, title="Ark.jl demo")

    world = World()
    add_resource!(world, size)
    add_resource!(world, WorldScreen(screen))

    scheduler = Scheduler(
        world,
        (
            RenderSystem(),
        ),
    )

    initialize!(scheduler)

    on(screen.render_tick) do _
        update!(scheduler)
    end

    GLMakie.renderloop(screen)
end

main()
