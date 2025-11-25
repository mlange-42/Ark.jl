using Ark
using Colors
using GLMakie
using GeometryBasics

include("../_common/scheduler.jl")
include("../_common/resources.jl")
include("../_common/terminate.jl")
include("components.jl")
include("resources.jl")
include("sys/grazer_init.jl")
include("sys/grass_growth.jl")
include("sys/grazer_movement.jl")
include("sys/grazer_feeding.jl")
include("sys/grazer_metabolism.jl")
include("sys/grazer_mortality.jl")
include("sys/grazer_decision.jl")
include("sys/grazer_reproduction.jl")
include("sys/grass_draw.jl")
include("sys/grazer_draw.jl")

const IS_CI = "CI" in keys(ENV)

function main()
    world = World(Position, Rotation, Energy, Genes, Moving, Grazing)

    size = WorldSize(80, 60, 10)
    add_resource!(world, size)

    window = setup_makie(size)
    add_resource!(world, window)

    add_resource!(world, SimulationSpeed(1))

    scheduler = Scheduler(
        world,
        (
            GrazerInit(count=1000),
            GrassGrowth(growth_rate=0.01),
            GrazerMovement(speed=0.1),
            GrazerFeeding(max_grazing=0.05, efficiency=1.0, threshold=0.1),
            GrazerReproduction(max_offspring=25, cross_rate=0.2, mutation_rate=0.01),
            GrazerMetabolism(base_rate=0.005, move_rate=0.01),
            GrazerMortality(),
            GrazerDecision(),
            GrassDraw(),
            GrazerDraw(),
            TerminationSystem(IS_CI ? 240 : -1), # Short run in CI tests
        ),
    )

    run!(world, scheduler)
end

function setup_makie(size::WorldSize)
    GLMakie.activate!(
        framerate=60.0,
        vsync=true,
        renderloop=GLMakie.renderloop,
        render_on_demand=true,
    )

    size = (size.width * size.scale, size.height * size.scale)
    f = Figure(figure_padding=1, size=(size[1] + 260, size[2]), backgroundcolor=:white)
    #colsize!(f.layout, 1, Fixed(size[1]))

    scene = LScene(
        f[1:3, 1], width=size[1], height=size[2],
        scenekw=(camera=campixel!, size=size, backgroundcolor=:black),
    )

    ax1 = Axis(f[1, 2], title="Scatter 1", backgroundcolor=:white)
    scatter!(ax1, rand(10), rand(10), color=:red)
    ylims!(ax1, low=0, high=1)
    xlims!(ax1, low=0, high=1)

    ax2 = Axis(f[2, 2], title="Scatter 2", backgroundcolor=:white)
    scatter!(ax2, rand(10), rand(10), color=:blue)
    ylims!(ax2, low=0, high=1)
    xlims!(ax2, low=0, high=1)

    ax3 = Axis(f[3, 2], title="Scatter 3", backgroundcolor=:white)
    scatter!(ax3, rand(10), rand(10), color=:green)
    ylims!(ax3, low=0, high=1)
    xlims!(ax3, low=0, high=1)

    screen = display(f)
    GLMakie.GLFW.SetWindowTitle(screen.glscreen, "Grazers demo")

    return Window(scene.scene, screen)
end

function run!(world::World, scheduler::Scheduler)
    initialize!(scheduler)

    window = get_resource(world, Window)
    speed = get_resource(world, SimulationSpeed)
    on(window.screen.render_tick) do _
        for _ in 1:speed.speed
            if !update!(scheduler)
                GLMakie.closeall()
            end
        end
    end

    GLMakie.start_renderloop!(window.screen)
    wait(window.screen)
end

main()
