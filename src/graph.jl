mutable struct _GraphNode{M,B1,B2}
    const mask::_Mask{M,B1}
    const neighbors::_VecMap{_GraphNode{M,B1,B2},M,B2}
    archetype::UInt32
end

function _GraphNode(mask::_Mask{1,B}, archetype::UInt32) where {B}
    _GraphNode(mask, _VecMap{_GraphNode{1,B,Bit},1}(), archetype)
end

function _GraphNode(mask::_Mask{M,B}, archetype::UInt32) where {M,B}
    _GraphNode(mask, _VecMap{_GraphNode{M,B},M,MVector{M,UInt64}}(), archetype)
end

struct _Graph{M,B1,B2}
    mask::_MutableMask{M,B2}
    nodes::Vector{_GraphNode{M,B1,B2}}
end

function _Graph{M}() where M
    _Graph(_MutableMask{M}(), [_GraphNode(_Mask{M}(), UInt32(1))])
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

function _find_node(g::_Graph, start::_GraphNode, add::Tuple{Vararg{Int}}, remove::Tuple{Vararg{Int}})
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
        elseif _get_bit(start.mask, b)
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
