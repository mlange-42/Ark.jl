
struct GrassGrowth <: System
    growth_rate::Float64
    feature_size::Float64
end

GrassGrowth(;
    growth_rate::Float64=0.01,
    feature_size::Float64=25.0,
) = GrassGrowth(growth_rate, feature_size)

function initialize!(s::GrassGrowth, world::World)
    size = get_resource(world, WorldSize)

    cap = zeros(Float64, size.width, size.height)
    sampler = fbm_fractal_2d(source=opensimplex2_2d(), octaves=4)
    scale = 1.0 / s.feature_size
    for x in 1:size.width, y in 1:size.height
        offset = 0.33
        cap[x, y] = clamp(sample(sampler, x * scale, y * scale) + offset, 0.01, 1)
    end

    grass = GrassGrid(cap, Observable(copy(cap)))
    add_resource!(world, grass)
end

function update!(s::GrassGrowth, world::World)
    grass = get_resource(world, GrassGrid)

    vals = grass.grass[]
    cap = grass.capacity
    r = s.growth_rate
    for j in axes(vals, 2), i in axes(vals, 1)
        v = vals[i, j]
        c = cap[i, j]
        v += r * v * (1.0 - v / c)
        vals[i, j] = clamp(v, 0, 1)
    end
end
