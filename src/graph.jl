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
    nodes::Dictionary{_Mask{M},_GraphNode{M}}
end

function _Graph{M}() where M
    g = _Graph{M}(_MutableMask{M}(), Dictionary{_Mask{M},_GraphNode{M}}())
    set!(g.nodes, _Mask{M}(), _GraphNode(_Mask{M}(), UInt32(1)))
    return g
end

function _find_or_create(g::_Graph, mask::_MutableMask)
    immut_mask = _Mask(mask)
    get!(() -> _GraphNode(immut_mask, typemax(UInt32)), g.nodes, immut_mask)
end

function _find_node(g::_Graph, start::_GraphNode, add::Tuple{Vararg{Int}}, remove::Tuple{Vararg{Int}}, 
        add_mask::_Mask, rem_mask::_Mask)
    if _is_not_zero(_clear_bits(rem_mask, start.mask))
        throw(ArgumentError("entity does not have component to remove"))
    elseif add_mask.bits != _clear_bits(add_mask, start.mask).bits
        throw(ArgumentError("entity already has component to add, or it was added twice"))
    end
    new_mask = _clear_bits(_or(add_mask, start.mask), rem_mask)
    get(() -> _create_path(g, start, add, remove), g.nodes, new_mask)
end

function _create_path(g, start, add, remove)
    curr = start
    _set_mask!(g.mask, start.mask)
    for b in remove
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
