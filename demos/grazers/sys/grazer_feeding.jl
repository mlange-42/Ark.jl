
struct GrazerFeeding <: System
    max_grazing::Float64
    efficiency::Float64
    threshold::Float64
end

GrazerFeeding(;
    max_grazing::Float64=0.05,
    efficiency::Float64=1.0,
    threshold::Float64=0.1,
) = GrazerFeeding(max_grazing, efficiency, threshold)

function update!(s::GrazerFeeding, world::World)
    grass = get_resource(world, GrassGrid).grass[]

    for (_, positions, energies) in Query(world, (Position, Energy); with=(Grazing,))
        for i in eachindex(positions, energies)
            pos = positions[i]
            cx, cy = floor(Int, pos[1]) + 1, floor(Int, pos[2]) + 1
            grass_here = grass[cx, cy]
            if grass_here <= s.threshold + s.max_grazing
                continue
            end
            grass[cx, cy] = grass_here - s.max_grazing
            energies[i] = Energy(clamp(energies[i].value + s.max_grazing * s.efficiency, 0, 1))
        end
    end
end
