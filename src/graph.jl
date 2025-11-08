mutable struct _GraphNode{K}
    const mask::_Mask{K}
    const neighbors::_VecMap{_GraphNode{K}}
    archetype::UInt32
end

function _GraphNode(mask::_Mask{K}, archetype::UInt32) where K
    _GraphNode{K}(mask, _VecMap{_GraphNode{K}}(), archetype)
end

struct _Graph{K}
    mask::_MutableMask{K}
    nodes::Vector{_GraphNode{K}}
end

function _Graph{K}() where K
    _Graph{K}(_MutableMask{K}(), [_GraphNode(_Mask{K}(), UInt32(1))])
end

function _find_or_create(g::_Graph, mask::_MutableMask)
    for node in g.nodes
        if _equals(mask, node.mask)
            return node
        end
    end
    push!(g.nodes, _GraphNode(_Mask(mask), typemax(UInt32)))
    return g.nodes[end]
end

function _find_node(g::_Graph, start::_GraphNode, add::Tuple{Vararg{UInt8}}, remove::Tuple{Vararg{UInt8}})
    curr = start

    _set_mask!(g.mask, start.mask)
    for b in remove
        if !_get_bit(g.mask, b)
            throw(ArgumentError("entity does not have component to remove"))
        end
        _clear_bit!(g.mask, b)

        if _get_bit(curr.neighbors.used, b)
            curr = curr.neighbors.data[b]
        else
            next = _find_or_create(g, g.mask)
            _set_map!(next.neighbors, b, curr)
            _set_map!(curr.neighbors, b, next)
            curr = next
        end
    end
    for b in add
        if _get_bit(g.mask, b)
            throw(ArgumentError("entity already has component to add, or it was added twice"))
        end
        if _get_bit(start.mask, b)
            throw(ArgumentError("component added and removed in the same exchange operation"))
        end
        _set_bit!(g.mask, b)

        if _get_bit(curr.neighbors.used, b)
            curr = curr.neighbors.data[b]
        else
            next = _find_or_create(g, g.mask)
            _set_map!(next.neighbors, b, curr)
            _set_map!(curr.neighbors, b, next)
            curr = next
        end
    end

    return curr
end
