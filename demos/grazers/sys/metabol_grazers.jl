
struct MetabolizeGrazers <: System
    base_rate::Float64
    move_rate::Float64
end

MetabolizeGrazers(;
    base_rate::Float64=0.01,
    move_rate::Float64=0.025,
) = MetabolizeGrazers(base_rate, move_rate)

function update!(s::MetabolizeGrazers, world::World)
    for (_, energy) in Query(world, (Energy,); with=(Grazing,))
        energy.value .-= s.base_rate
        energy.value .= clamp.(energy.value, 0, 1)
    end
    for (_, energy) in Query(world, (Energy,); with=(Moving,))
        energy.value .-= s.move_rate
        energy.value .= clamp.(energy.value, 0, 1)
    end
end
