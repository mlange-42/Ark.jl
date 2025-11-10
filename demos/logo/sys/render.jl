
mutable struct RenderSystem
    img_data::Union{Array{UInt8,2},Nothing}
    img_node::Union{GLMakie.Observable{Array{UInt8,2}},Nothing}
end

RenderSystem() = RenderSystem(nothing, nothing)

function initialize!(s::RenderSystem, world::World)
    size = get_resource(world, WorldSize)
    screen = get_resource(world, WorldScreen)

    scene = Scene(camera=campixel!, size=(size.width, size.height))
    display(screen.screen, scene)

    s.img_data = rand(UInt8, size.width, size.height)
    s.img_node = Observable(s.img_data)
    image!(scene, s.img_node)
end

function update!(s::RenderSystem, world::World)
    size = get_resource(world, WorldSize)
    for i in 1:1000
        x = rand(1:size.width)
        y = rand(1:size.height)
        s.img_data[x, y] = 0
    end
    s.img_node[] = s.img_data
end
