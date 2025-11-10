using GLMakie

size = (800, 600)

GLMakie.activate!(renderloop=GLMakie.renderloop)

screen = GLMakie.Screen(framerate=60.0, vsync=true, render_on_demand=false, title="Ark.jl demo")
scene = Scene(camera=campixel!, size=size)
display(screen, scene)

img_data = rand(UInt8, size...)
img_node = Observable(img_data)
image!(scene, img_node)

on(screen.render_tick) do _
    x = rand(1:size[1])
    y = rand(1:size[2])
    img_data[x, y] = 0
    img_node[] = img_data
end

GLMakie.renderloop(screen)
