
struct GrazerMetabolism <: System
    base_rate::Float64
    move_rate::Float64
end

GrazerMetabolism(;
    base_rate::Float64=0.01,
    move_rate::Float64=0.025,
) = GrazerMetabolism(base_rate, move_rate)

function update!(s::GrazerMetabolism, world::World)
    for (_, energy) in Query(world, (Energy,); with=(Grazing,))
        energy.value .-= s.base_rate
        energy.value .= clamp.(energy.value, 0, 1)
    end
    for (_, energy) in Query(world, (Energy,); with=(Moving,))
        energy.value .-= s.move_rate
        energy.value .= clamp.(energy.value, 0, 1)
    end
end
