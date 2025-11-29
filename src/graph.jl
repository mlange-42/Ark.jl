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
    nodes::Dict{_Mask{M},_GraphNode{M}}
end

function _Graph{M}() where M
    _Graph{M}(_MutableMask{M}(), Dict(_Mask{M}() => _GraphNode(_Mask{M}(), UInt32(1))))
end

function _find_or_create(g::_Graph, mask::_MutableMask)
    immut_mask = _Mask(mask)
    get!(() -> _GraphNode(immut_mask, typemax(UInt32)), g.nodes, immut_mask)
end

function _find_node(g::_Graph, start::_GraphNode, add::Tuple{Vararg{Int}}, remove::Tuple{Vararg{Int}})
    curr = start

    _set_mask!(g.mask, start.mask)
    for b in remove
        if !_get_bit(g.mask, b)
            throw(ArgumentError("entity does not have component to remove"))
        end
        _clear_bit!(g.mask, b)

        if _in_map(curr.neighbors, b)
            curr = _get_map(curr.neighbors, b)
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

        if _in_map(curr.neighbors, b)
            curr = _get_map(curr.neighbors, b)
        else
            next = _find_or_create(g, g.mask)
            _set_map!(next.neighbors, b, curr)
            _set_map!(curr.neighbors, b, next)
            curr = next
        end
    end

    return curr
end
