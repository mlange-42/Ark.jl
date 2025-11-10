module Logo

using Ark
using GLMakie
using Colors
using Images
using FixedPointNumbers

include("util.jl")
include("scheduler.jl")
include("components.jl")
include("resources.jl")
include("sys/setup.jl")
include("sys/render.jl")
include("sys/mouse.jl")
include("sys/movement.jl")

const IMAGE_PATH = string(dirname(dirname(pathof(Ark)))) * "/docs/src/assets/preview.png"

function __init__()
    GLMakie.activate!(renderloop=GLMakie.renderloop, focus_on_show=true)

    world = World(Position, Velocity, Target)
    add_resource!(world, WorldSize(1000, 600))
    add_resource!(world, Logo(load(IMAGE_PATH)[1:2:end, 1:2:end]))

    scheduler = Scheduler(
        world,
        (
            SetupSystem(),
            MovementSystem(),
            RenderSystem(),
            MouseSystem(),
        ),
    )

    initialize!(scheduler)

    screen = get_resource(world, WorldScreen)
    on(screen.screen.render_tick) do _
        update!(scheduler)
    end

    GLMakie.renderloop(screen.screen)
end

end
