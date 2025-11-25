mutable struct _GraphNode{M}
    const mask::_Mask{M}
    const neighbors::_VecMap{_GraphNode{M},M}
    archetype::UInt32
end

function _GraphNode(mask::_Mask{M}, archetype::UInt32) where M
    _GraphNode{M}(mask, _VecMap{_GraphNode{M},M}(), archetype)
end

struct _Graph{M}
    mask::_MutableMask{M}
    nodes::Vector{_GraphNode{M}}
end

function _Graph{M}() where M
    _Graph{M}(_MutableMask{M}(), [_GraphNode(_Mask{M}(), UInt32(1))])
end

function _find_or_create(g::_Graph, mask::_MutableMask)
    for node in g.nodes
        if _equals(mask, node.mask)
            return node
        end
    end
    node = _GraphNode(_Mask(mask), typemax(UInt32))
    push!(g.nodes, node)
    return node
end

function _find_node(g::_Graph, start::_GraphNode, add::Tuple{Vararg{Int}}, remove::Tuple{Vararg{Int}})
    curr = start

    _set_mask!(g.mask, start.mask)
    for b in remove
        if !_get_bit(start.mask, b)
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
        if _get_bit(start.mask, b)
            throw(ArgumentError("entity already has component to add"))
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
