using GLMakie
using GeometryBasics

function main()
    GLMakie.activate!(
        framerate=60.0,
        vsync=true,
        renderloop=GLMakie.renderloop,
        render_on_demand=true,
    )
    scene = Scene(camera=campixel!, size=(800, 600), backgroundcolor=:black)
    screen = display(scene)

    boid_shape = Polygon(Point2f[(0, 3), (4, -5), (0, -3), (-4, -5)])

    positions = Observable([Point2f(rand() * 800, rand() * 600) for _ in 1:100])
    rotations = Observable([rand() * 2π for _ in 1:100])

    meshscatter!(scene, positions; rotation=rotations, marker=boid_shape, color=:green, markersize=1)

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
