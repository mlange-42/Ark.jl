
mutable struct RenderSystem
    img_data::Union{Array{Gray{N0f8},2},Nothing}
    img_node::Union{GLMakie.Observable{Array{Gray{N0f8},2}},Nothing}
end

RenderSystem() = RenderSystem(nothing, nothing)

function initialize!(s::RenderSystem, world::World)
    size = get_resource(world, WorldSize)
    screen = get_resource(world, WorldScreen)

    scene = Scene(camera=campixel!, size=(size.width, size.height))
    display(screen.screen, scene)

    s.img_data = zeros(Gray{N0f8}, size.width, size.height)
    s.img_node = Observable(s.img_data)
    image!(scene, s.img_node)
end

function update!(s::RenderSystem, world::World)
    size = get_resource(world, WorldSize)
    data = s.img_data
    fill!(data, 0)
    for i in 1:1000
        x = rand(1:size.width)
        y = rand(1:size.height)
        data[x, y] = 1
    end
    s.img_node[] = data
end
