using Ark
using Colors
using GLMakie

include("../_common/scheduler.jl")
include("../_common/resources.jl")
include("../_common/terminate.jl")
include("components.jl")
include("resources.jl")
include("sys/network_init.jl")

const IS_CI = "CI" in keys(ENV)

function main()
    world = World()

    size = WorldSize(800, 600)
    add_resource!(world, size)

    setup_makie(world, size)

    scheduler = Scheduler(
        world,
        (
            NetworkInit(count=1000),
            TerminationSystem(IS_CI ? 240 : -1), # Short run in CI tests
        ),
    )

    run!(world, scheduler)
end

function setup_makie(world::World, size::WorldSize)
    GLMakie.activate!(
        framerate=60.0,
        vsync=true,
        renderloop=GLMakie.renderloop,
        render_on_demand=true,
    )

    f = Figure(backgroundcolor=:white)

    screen = display(f)
    GLMakie.GLFW.SetWindowTitle(screen.glscreen, "Network demo")

    add_resource!(world, Window(screen))
end

function run!(world::World, scheduler::Scheduler)
    initialize!(scheduler)

    window = get_resource(world, Window)
    on(window.screen.render_tick) do _
        if !update!(scheduler)
            GLMakie.closeall()
        end
    end

    GLMakie.start_renderloop!(window.screen)
    wait(window.screen)
end

main()
