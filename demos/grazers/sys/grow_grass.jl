
struct GrowGrass <: System
    growth_rate::Float64
end

GrowGrass(;
    growth_rate::Float64=0.01,
) = GrowGrass(growth_rate)

function initialize!(s::GrowGrass, world::World)
    size = get_resource(world, WorldSize)
    grass = GrassGrid(Observable([rand() * 0.25 + 0.25 for x in 1:size.width, y in 1:size.height]))
    add_resource!(world, grass)
end

function update!(s::GrowGrass, world::World)
    grass = get_resource(world, GrassGrid)

    vals = grass.grass[]
    r = s.growth_rate
    for j in axes(vals, 2), i in axes(vals, 1)
        v = vals[i, j]
        v += r * v * (1.0 - v)
        vals[i, j] = clamp(v, 0, 1)
    end
end
