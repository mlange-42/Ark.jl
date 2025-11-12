module Logo

using Ark
using MiniFB
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
    while mfb_wait_sync(screen.screen)
        if !update!(scheduler)
            break
        end
        image = get_resource(world, WorldImage)
        state = mfb_update(screen.screen, image.image)
        if state != MiniFB.STATE_OK
            break
        end
    end
    mfb_close(screen.screen)

    finalize!(scheduler)
    println("Finished after $(get_resource(world, Tick).tick) ticks")
end

end
