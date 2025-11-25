using Ark
using Colors
using GLMakie
using GeometryBasics

include("../_common/scheduler.jl")
include("../_common/resources.jl")
include("../_common/terminate.jl")
include("resources.jl")
include("sys/draw_grass.jl")
include("sys/draw_grazers.jl")

const IS_CI = "CI" in keys(ENV)

function main()
    size = WorldSize(80, 60, 10)
    GLMakie.activate!(
        framerate=60.0,
        vsync=true,
        renderloop=GLMakie.renderloop,
        render_on_demand=true,
    )
    scene = Scene(camera=campixel!, size=(size.width * size.scale, size.height * size.scale), backgroundcolor=:black)
    screen = display(scene)

    world = World()
    add_resource!(world, size)
    grass = GrassGrid(Observable([sin(x / 10) * cos(y / 10) for x in 1:size.width, y in 1:size.height]))
    add_resource!(world, grass)
    add_resource!(world, Window(scene, screen))

    scheduler = Scheduler(
        world,
        (
            DrawGrass(),
            DrawGrazers(),
            TerminationSystem(IS_CI ? 240 : -1), # Short run in CI tests
        ),
    )

    initialize!(scheduler)

    on(screen.render_tick) do _
        if !update!(scheduler)
            GLMakie.closeall()
        end
    end

    GLMakie.start_renderloop!(screen)
    wait(screen)
end

main()
