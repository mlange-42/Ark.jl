module Logo

using Ark
using GLMakie
using Colors
using Images
using FixedPointNumbers

include("../_common/scheduler.jl")
include("../_common/resources.jl")
include("../_common/profile.jl")
include("../_common/terminate.jl")
include("components.jl")
include("resources.jl")
include("sys/setup.jl")
include("sys/render.jl")
include("sys/mouse.jl")
include("sys/movement.jl")

const IS_CI = "CI" in keys(ENV)
const IMAGE_PATH = string(dirname(dirname(pathof(Ark)))) * "/docs/src/assets/preview.png"

function __init__()
    GLMakie.activate!(
        framerate=60.0,
        vsync=true,
        renderloop=GLMakie.renderloop,
        render_on_demand=true,
        focus_on_show=!IS_CI,
    )

    world = World(Position, Velocity, Target)
    add_resource!(world, WorldSize(1000, 600))
    add_resource!(world, ArkLogo(load(IMAGE_PATH)[1:2:end, 1:2:end]))

    scheduler = Scheduler(
        world,
        (
            SetupSystem(),
            MovementSystem(),
            RenderSystem(),
            MouseSystem(),
            ProfilingSystem(60),
            TerminationSystem(IS_CI ? 100 : -1), # Short run in CI tests
        ),
    )

    initialize!(scheduler)

    screen = get_resource(world, WorldScreen)
    on(screen.screen.render_tick) do _
        if !update!(scheduler)
            @async begin
                sleep(0.0)
                GLMakie.closeall()
            end
        end
    end

    # @async while true
    #     if !update!(scheduler)
    #         break
    #     end
    #     sleep(1 / 60)
    # end

    GLMakie.renderloop(screen.screen)

    finalize!(scheduler)
    println("Finished after $(get_resource(world, Tick).tick) ticks")
end

end
