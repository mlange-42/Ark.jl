
mutable struct _EntityPool
    const entities::Vector{Entity}
    next::UInt32
    available::UInt32
end

function _EntityPool(initialCap::UInt32)
    v = [_new_entity(UInt32(0), typemax(UInt32))]
    sizehint!(v, initialCap)

    return _EntityPool(v, 0, 0)
end

function _get_entity(p::_EntityPool)::Entity
    if p.available == 0
        return _get_new_entity(p)
    end
    curr = p.next
    p.next = p.entities[_convert(Int, p.next)]._id

    temp = p.entities[_convert(Int, curr)]
    p.entities[_convert(Int, curr)] = Entity(curr, temp._gen)

    p.available -= 1
    return p.entities[_convert(Int, curr)]
end

function _get_new_entity(p::_EntityPool)::Entity
    e = _new_entity(length(p.entities) + 1, 0)
    push!(p.entities, e)
    return e
end

function _recycle(p::_EntityPool, e::Entity)
    if e._id < 2
        error("can't recycle reserved zero entity")
    end
    temp = p.next
    p.next = e._id
    p.entities[e._id] = _new_entity(temp, e._gen + UInt32(1))
    p.available += 1
end

function _is_alive(p::_EntityPool, e::Entity)::Bool
    @inbounds return e._gen == p.entities[e._id]._gen
end

mutable struct _BitPool
    const bits::Vector{UInt8}
    length::UInt8
    next::UInt8
    available::UInt8
end

function _BitPool()
    return _BitPool(zeros(UInt8, 64), 0, 0, 0)
end

function _get_bit(p::_BitPool)::UInt8
    if p.available == 0
        return _get_new_bit(p)
    end
    curr = p.next
    p.next = p.bits[p.next]
    p.bits[curr] = curr

    p.available -= 1
    return p.bits[curr]
end

function _get_new_bit(p::_BitPool)::UInt8
    if p.length >= 64
        error(string("run out of the maximum of 64 bits. ",
            "This is likely caused by unclosed queries that lock the world. ",
            "Make sure that all queries finish their iteration or are closed manually"))
    end
    b = p.length + 1
    p.bits[p.length+1] = b
    p.length += 1
    return b
end

function _recycle(p::_BitPool, b::UInt8)
    temp = p.next
    p.next = b
    p.bits[b] = temp
    p.available += 1
end
