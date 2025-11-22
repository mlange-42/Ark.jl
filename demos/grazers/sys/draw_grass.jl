
mutable struct DrawGrass <: System
end

function initialize!(s::DrawGrass, world::World)
    size = get_resource(world, WorldSize)
    win = get_resource(world, Window)
    grass = get_resource(world, GrassGrid)

    black_to_green = [RGB(0, 0, 0), RGB(0, 1, 0)]
    hm = heatmap!(win.scene, 1:size.width, 1:size.height, grass.grass, colormap=black_to_green, colorrange=(0, 1))

    Makie.transform!(hm, scale=Vec3f(size.scale, size.scale, 1))
end

function update!(s::DrawGrass, world::World)
    grass = get_resource(world, GrassGrid)
    notify(grass.grass)
end
