
struct NetworkPlot <: System
end

function initialize!(s::NetworkPlot, world::World)
    data = get_resource(world, PlotData)
    node_data = data.nodes[]
    edge_data = data.edges[]

    resize!(node_data, 0)
    resize!(edge_data, 0)

    for (_, positions) in Query(world, (Position,))
        append!(node_data, positions)
    end
    for (_, edges) in Query(world, (EdgePosition,))
        for edge in edges
            push!(edge_data, (edge.node_a, edge.node_b))
        end
    end

    notify(data.nodes)
    notify(data.edges)
end
