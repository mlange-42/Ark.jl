
struct DrawGrazers <: System
end

function initialize!(s::DrawGrazers, world::World)
    size = get_resource(world, WorldSize)
    win = get_resource(world, Window)

    boid_shape = Polygon(Point2f[(3, 0), (-5, 4), (-3, 0), (-5, -4)])

    positions = Observable(Point2f[])
    rotations = Observable(Float64[])

    add_resource!(world, Grazers(positions, rotations))

    sc = meshscatter!(win.scene, positions; rotation=rotations, marker=boid_shape, color=:blue, markersize=0.1)

    Makie.transform!(sc, scale=Vec3f(size.scale, size.scale, 1))
end

function update!(s::DrawGrazers, world::World)
    grazers = get_resource(world, Grazers)
    pos = grazers.positions[]
    rot = grazers.rotations[]

    resize!(pos, 0)
    resize!(rot, 0)

    for (_, positions, rotations) in Query(world, (Position, Rotation))
        append!(pos, positions)
        append!(rot, rotations)
    end

    notify(grazers.positions)
    notify(grazers.rotations)
end
