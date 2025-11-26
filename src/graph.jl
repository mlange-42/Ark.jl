mutable struct _GraphNode{M}
    const index::Int
    const mask::_Mask{M}
    const neighbors::_VecMap{M}
    archetype::UInt32
end

function _GraphNode(index::Int, mask::_Mask{M}, archetype::UInt32) where M
    _GraphNode{M}(index, mask, _VecMap{M}(), archetype)
end

struct _Graph{M}
    mask::_MutableMask{M}
    nodes::Vector{_GraphNode{M}}
end

function _Graph{M}() where M
    _Graph{M}(_MutableMask{M}(), [_GraphNode(1, _Mask{M}(), UInt32(1))])
end

function _find_or_create(g::_Graph, mask::_MutableMask)
    for node in g.nodes
        if _equals(mask, node.mask)
            return node
        end
    end
    new_node = _GraphNode(length(g.nodes) + 1, _Mask(mask), typemax(UInt32))
    push!(g.nodes, new_node)
    return new_node
end

function _find_node(g::_Graph, start::_GraphNode, add::Tuple{Vararg{Int}}, remove::Tuple{Vararg{Int}})
    curr = start
    _set_mask!(g.mask, start.mask)

    for b in remove
        if !_get_bit(g.mask, b)
            throw(ArgumentError("entity does not have component to remove"))
        end
        _clear_bit!(g.mask, b)

        if _get_bit(curr.neighbors.used, b)
            next_id = curr.neighbors.data[b]
            curr = g.nodes[next_id]
        else
            next = _find_or_create(g, g.mask)
            _set_map!(next.neighbors, b, curr.index)
            _set_map!(curr.neighbors, b, next.index)
            curr = next
        end
    end

    for b in add
        if _get_bit(g.mask, b)
            throw(ArgumentError("entity already has component to add, or it was added twice"))
        elseif _get_bit(start.mask, b)
            throw(ArgumentError("component added and removed in the same exchange operation"))
        end
        _set_bit!(g.mask, b)

        if _get_bit(curr.neighbors.used, b)
            next_id = curr.neighbors.data[b]
            curr = g.nodes[next_id]
        else
            next = _find_or_create(g, g.mask)
            _set_map!(next.neighbors, b, curr.index)
            _set_map!(curr.neighbors, b, next.index)
            curr = next
        end
    end

    return curr
end
