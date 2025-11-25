
mutable struct DrawGrazers <: System
end

function initialize!(s::DrawGrazers, world::World)
    size = get_resource(world, WorldSize)
    win = get_resource(world, Window)

    boid_shape = Polygon(Point2f[(0, 3), (4, -5), (0, -3), (-4, -5)])

    positions = Observable([Point2f(rand() * size.width, rand() * size.height) for _ in 1:100])
    rotations = Observable([rand() * 2π for _ in 1:100])

    sc = meshscatter!(win.scene, positions; rotation=rotations, marker=boid_shape, color=:blue, markersize=0.1)

    Makie.transform!(sc, scale=Vec3f(size.scale, size.scale, 1))
end
