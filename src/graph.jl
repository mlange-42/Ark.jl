mutable struct _GraphNode
    mask::_Mask
    neighbors::_VecMap{_GraphNode}
    archetype::UInt32
end

function _GraphNode(mask::_Mask, archetype::UInt32)
    _GraphNode(mask, _VecMap{_GraphNode}(), archetype)
end

struct _Graph
    nodes::Vector{_GraphNode}
end

function _Graph()
    _Graph([_GraphNode(_Mask(), UInt32(1))])
end

function _find_or_create(g::_Graph, mask::_MutableMask)::_GraphNode
    for node in g.nodes
        if _equals(mask, node.mask)
            return node
        end
    end
    push!(g.nodes, _GraphNode(_Mask(mask), typemax(UInt32)))
    return g.nodes[end]
end

function _find_node(g::_Graph, start::_GraphNode, add::Tuple{Vararg{UInt8}}, remove::Tuple{Vararg{UInt8}})::_GraphNode
    curr::_GraphNode = start

    mask = _MutableMask(start.mask)
    for b in remove
        if !_get_bit(mask, b)
            error("entity does not have component to remove")
        end
        _clear_bit!(mask, b)

        if _get_bit(curr.neighbors.used, b)
            curr = curr.neighbors.data[b]
        else
            next = _find_or_create(g, mask)
            _set_map!(next.neighbors, b, curr)
            _set_map!(curr.neighbors, b, next)
            curr = next
        end
    end
    for b in add
        if _get_bit(mask, b)
            error("entity already has component to add, or it was added twice")
        end
        if _get_bit(start.mask, b)
            error("component added and removed in the same exchange operation")
        end
        _set_bit!(mask, b)

        if _get_bit(curr.neighbors.used, b)
            curr = curr.neighbors.data[b]
        else
            next = _find_or_create(g, mask)
            _set_map!(next.neighbors, b, curr)
            _set_map!(curr.neighbors, b, next)
            curr = next
        end
    end

    return curr
end
