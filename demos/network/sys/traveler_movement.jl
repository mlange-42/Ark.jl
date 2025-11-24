
struct TravelerMovement <: System
    speed::Float64
end

TravelerMovement(;
    speed::Float64=1.0,
) = TravelerMovement(speed)

function update!(s::TravelerMovement, world::World)
    for (_, travelers, positions) in Query(world, (Traveler, Position))
        travelers.position .+= s.speed
        for i in eachindex(travelers, positions)
            traveler = travelers[i]
            new_fwd = traveler.forward
            new_pos = traveler.position + s.speed
            new_edge = traveler.edge

            edge, edge_pos, edge_len = get_components(world, new_edge, (Edge, EdgePosition, EdgeLength))

            if traveler.position > edge_len.length
                offset = traveler.position - edge_len.length
                node_entity = new_fwd ? edge.node_b : edge.node_a
                node, = get_components(world, node_entity, (Node,))
                while true
                    new_edge = rand(node.edges)
                    if new_edge != traveler.edge
                        break
                    end
                end
                edge, edge_pos, edge_len = get_components(world, new_edge, (Edge, EdgePosition, EdgeLength))
                new_fwd = edge.node_a == node_entity
                new_pos = offset
            end

            travelers[i] = Traveler(new_edge, new_pos, new_fwd)
            positions[i] = position(new_pos, new_fwd, edge_pos, edge_len)
        end
    end
end
