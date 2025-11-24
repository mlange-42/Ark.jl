function position(p::Float64, fwd::Bool, edge::EdgePosition, len::EdgeLength)
    rel_pos = p / len.length
    if !fwd
        rel_pos = 1 - rel_pos
    end
    x = edge.node_a[1] + (edge.node_b[1] - edge.node_a[1]) * rel_pos
    y = edge.node_a[2] + (edge.node_b[2] - edge.node_a[2]) * rel_pos
    return Position(x, y)
end
