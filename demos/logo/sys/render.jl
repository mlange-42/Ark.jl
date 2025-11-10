
mutable struct RenderSystem <: System
    img_data::Union{Array{Gray{N0f8},2},Nothing}
    img_node::Union{GLMakie.Observable{Array{Gray{N0f8},2}},Nothing}
end

RenderSystem() = RenderSystem(nothing, nothing)

function initialize!(s::RenderSystem, world::World)
    size = get_resource(world, WorldSize)

    scene = Scene(camera=campixel!, size=(size.width, size.height))
    add_resource!(world, WorldScene(scene))

    screen = GLMakie.Screen(framerate=60.0, vsync=true, render_on_demand=false, title="Ark.jl demo")
    add_resource!(world, WorldScreen(screen))
end

function update!(s::RenderSystem, world::World)
    size = get_resource(world, WorldSize)
    if s.img_node === nothing
        s.img_data = zeros(Gray{N0f8}, size.width, size.height)
        s.img_node = Observable(s.img_data)

        scene = get_resource(world, WorldScene)
        screen = get_resource(world, WorldScreen)
        display(screen.screen, scene.scene)

        image!(scene.scene, s.img_node)
    end

    data = s.img_data
    fill!(data, 0)
    for (_, positions) in @Query(world, (Position,))
        @inbounds for i in eachindex(positions)
            pos = positions[i]
            if !contains(size, pos.x, pos.y)
                continue
            end
            data[round(Int, pos.x), round(Int, pos.y)] = 1
        end
    end
    s.img_node[] = data
end
