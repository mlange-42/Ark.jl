
struct UpdatePlots <: System
end

function update!(s::UpdatePlots, world::World)
    tick = get_resource(world, Tick)

    if tick.tick % 60 != 0
        return
    end

    data = get_resource(world, PlotData)
    energy = data.energy[]
    max_angle = data.max_angle[]
    move_thresh = data.move_thresh[]
    graze_thresh = data.graze_thresh[]
    num_offspring = data.num_offspring[]
    energy_share = data.energy_share[]

    resize!(energy, 0)
    resize!(max_angle, 0)
    resize!(move_thresh, 0)
    resize!(graze_thresh, 0)
    resize!(num_offspring, 0)
    resize!(energy_share, 0)

    for (_, genes, energies) in Query(world, (Genes, Energy))
        append!(energy, energies.value)
        append!(max_angle, genes.max_angle)
        append!(move_thresh, genes.move_thresh)
        append!(graze_thresh, genes.graze_thresh)
        append!(num_offspring, genes.num_offspring)
        append!(energy_share, genes.energy_share)
    end

    notify(data.energy)
    notify(data.max_angle)
    notify(data.move_thresh)
    notify(data.graze_thresh)
    notify(data.num_offspring)
    notify(data.energy_share)
end
