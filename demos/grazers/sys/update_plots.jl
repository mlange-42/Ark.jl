
struct UpdatePlots <: System
end

function update!(s::UpdatePlots, world::World)
    tick = get_resource(world, Tick)

    if tick.tick % 60 != 0
        return
    end

    data = get_resource(world, PlotData)
    max_angle = data.max_angle[]
    reverse_prob = data.reverse_prob[]
    move_thresh = data.move_thresh[]
    graze_thresh = data.graze_thresh[]
    num_offspring = data.num_offspring[]
    energy_share = data.energy_share[]

    resize!(max_angle, 0)
    resize!(reverse_prob, 0)
    resize!(move_thresh, 0)
    resize!(graze_thresh, 0)
    resize!(num_offspring, 0)
    resize!(energy_share, 0)

    for (_, genes) in Query(world, (Genes,))
        append!(max_angle, genes.max_angle)
        append!(reverse_prob, genes.reverse_prob)
        append!(move_thresh, genes.move_thresh)
        append!(graze_thresh, genes.graze_thresh)
        append!(num_offspring, genes.num_offspring)
        append!(energy_share, genes.energy_share)
    end

    notify(data.max_angle)
    notify(data.reverse_prob)
    notify(data.move_thresh)
    notify(data.graze_thresh)
    notify(data.num_offspring)
    notify(data.energy_share)
end
