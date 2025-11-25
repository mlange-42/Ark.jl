using Ark
using GLMakie
using GeometryBasics

include("resources.jl")

function main()
    width = 80
    height = 60
    GLMakie.activate!(
        framerate=60.0,
        vsync=true,
        renderloop=GLMakie.renderloop,
        render_on_demand=true,
    )
    scene = Scene(camera=campixel!, size=(width * 10, height * 10), backgroundcolor=:black)
    screen = display(scene)

    world = World()
    grass = GrassGrid(Observable([sin(x / 10) * cos(y / 10) for x in 1:width, y in 1:height]))
    add_resource!(world, grass)

    hm = heatmap!(scene, 1:width, 1:height, grass.grass, colormap=:viridis)

    boid_shape = Polygon(Point2f[(0, 3), (4, -5), (0, -3), (-4, -5)])

    positions = Observable([Point2f(rand() * 80, rand() * 60) for _ in 1:100])
    rotations = Observable([rand() * 2π for _ in 1:100])

    sc = meshscatter!(scene, positions; rotation=rotations, marker=boid_shape, color=:green, markersize=0.1)

    Makie.transform!(hm, scale=Vec3f(10, 10, 1))
    Makie.transform!(sc, scale=Vec3f(10, 10, 1))

    on(screen.render_tick) do _
        for i in eachindex(rotations[])
            rotations[][i] += 0.01
        end
        notify(rotations)
    end

    GLMakie.start_renderloop!(screen)
    wait(screen)
end

main()
