using GLMakie

function main()
    GLMakie.activate!(
        framerate=60.0,
        vsync=true,
        renderloop=GLMakie.renderloop,
        render_on_demand=true,
    )
    scene = Scene(camera=campixel!, size=(800, 600))
    screen = display(scene)

    on(screen.render_tick) do _
        println("render")
    end

    GLMakie.start_renderloop!(screen)
    wait(screen)
end

main()
