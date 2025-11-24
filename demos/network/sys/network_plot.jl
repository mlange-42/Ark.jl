
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
    for (_, edges) in Query(world, (Edge,))
        for edge in edges
            p1, = get_components(world, edge.node_a, (Position,))
            p2, = get_components(world, edge.node_b, (Position,))
            push!(edge_data, (p1, p2))
        end
    end

    notify(data.nodes)
    notify(data.edges)
end
