using GLMakie
using Dates

size = (800, 600)

GLMakie.activate!(renderloop=GLMakie.renderloop)

screen = GLMakie.Screen(framerate=60.0, vsync=true, render_on_demand=false, title="Ark.jl demo")
scene = Scene(camera=campixel!, size=size)
display(screen, scene)

img_data = rand(UInt8, size...)
img_node = Observable(img_data)
image!(scene, img_node)

last_time = Ref(now())

on(screen.render_tick) do _
    for i in 1:1000
        x = rand(1:size[1])
        y = rand(1:size[2])
        img_data[x, y] = 0
    end
    img_node[] = img_data
    current_time = now()
    fps = 1 / (Millisecond(current_time - last_time[]).value / 1000)
    last_time[] = current_time
end

GLMakie.renderloop(screen)
