
struct NetworkPlot <: System
end

function initialize!(s::NetworkPlot, world::World)
    data = get_resource(world, PlotData)
    nodes = data.nodes[]

    resize!(nodes, 0)

    for (_, positions) in Query(world, (Position,))
        append!(nodes, positions)
    end

    notify(data.nodes)
end

function update!(s::NetworkPlot, world::World)
end
