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

function main()
    GLMakie.activate!(renderloop=GLMakie.renderloop, focus_on_show=true)

    size = WorldSize(1000, 600)

    world = World(Position, Velocity, Target)

    add_resource!(world, size)
    add_resource!(world, Logo(load(IMAGE_PATH)[1:2:end, 1:2:end]))

    scheduler = Scheduler(
        world,
        (
            SetupSystem(),
            RenderSystem(),
            MouseSystem(),
            MovementSystem(
                max_speed=10.0,
                max_acc=0.08,
                max_acc_flee=0.1,
                min_flee_distance=50.0,
                max_flee_distance=200.0,
                damp=0.975,
            ),
        ),
    )

    initialize!(scheduler)

    screen = get_resource(world, WorldScreen)
    on(screen.screen.render_tick) do _
        update!(scheduler)
    end

    GLMakie.renderloop(screen.screen)
end

main()
