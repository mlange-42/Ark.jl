using Ark
using Colors
using GLMakie
using GeometryBasics

include("../_common/scheduler.jl")
include("../_common/resources.jl")
include("../_common/terminate.jl")
include("components.jl")
include("resources.jl")
include("sys/init_grazers.jl")
include("sys/grow_grass.jl")
include("sys/move_grazers.jl")
include("sys/metabol_grazers.jl")
include("sys/mortality_grazers.jl")
include("sys/decision_grazers.jl")
include("sys/draw_grass.jl")
include("sys/draw_grazers.jl")

const IS_CI = "CI" in keys(ENV)

function main()
    world = World(Position, Rotation, Energy, Genes, Moving, Grazing)

    size = WorldSize(80, 60, 10)
    add_resource!(world, size)

    window = setup_makie(size)
    add_resource!(world, window)

    scheduler = Scheduler(
        world,
        (
            InitGrazers(count=1000),
            GrowGrass(growth_rate=0.01),
            MoveGrazers(speed=0.1),
            MetabolizeGrazers(base_rate=0.01, move_rate=0.025),
            MortalityGrazers(),
            DecisionGrazers(),
            DrawGrass(),
            DrawGrazers(),
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
    scene = Scene(camera=campixel!, size=(size.width * size.scale, size.height * size.scale), backgroundcolor=:black)
    screen = display(scene)
    GLMakie.GLFW.SetWindowTitle(screen.glscreen, "Grazers demo")

    return Window(scene, screen)
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
