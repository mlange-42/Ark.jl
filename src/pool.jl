
mutable struct _EntityPool
    const entities::Vector{Entity}
    next::UInt32
    available::UInt32
end

function _EntityPool(cap::UInt32)
    v = [_new_entity(UInt32(0), typemax(UInt32))]
    sizehint!(v, cap)

    return _EntityPool(v, 0, 0)
end

function _get_entity(p::_EntityPool)::Entity
    if p.available == 0
        return _get_new_entity(p)
    end
    curr = p.next
    p.next = p.entities[p.next]._id

    temp = p.entities[curr]
    entity = Entity(curr, temp._gen)
    p.entities[curr] = entity

    p.available -= 1
    return entity
end

function _get_new_entity(p::_EntityPool)::Entity
    e = _new_entity(length(p.entities) + 1, 0)
    push!(p.entities, e)
    return e
end

function _recycle(p::_EntityPool, e::Entity)
    if e._id < 2
        throw(ArgumentError("can't recycle the reserved zero entity"))
    end
    temp = p.next
    p.next = e._id
    p.entities[e._id] = _new_entity(temp, e._gen + UInt32(1))
    p.available += 1
    return nothing
end

function _is_alive(p::_EntityPool, e::Entity)::Bool
    @inbounds return e._gen == p.entities[e._id]._gen
end

function _reset!(p::_EntityPool)
    resize!(p.entities, 1)
    p.next = 0
    p.available = 0
end

mutable struct _BitPool
    const bits::Vector{Int}
    length::UInt8
    next::UInt8
    available::UInt8
end

function _BitPool()
    return _BitPool(zeros(UInt8, 64), 0, 0, 0)
end

function _get_bit(p::_BitPool)::Int
    if p.available == 0
        return _get_new_bit(p)
    end
    curr = p.next
    p.next = p.bits[p.next]
    p.bits[curr] = curr

    p.available -= 1
    return curr
end

function _get_new_bit(p::_BitPool)::Int
    if p.length >= 64
        throw(
            InvalidStateException(
                string("run out of the maximum of 64 bits. ",
                    "This is likely caused by unclosed queries that lock the world. ",
                    "Make sure that all queries finish their iteration or are closed manually"),
                :locks_exhausted,
            ),
        )
    end
    b = p.length + 1
    p.bits[p.length+1] = b
    p.length += 1
    return b
end

function _recycle(p::_BitPool, b::Int)
    temp = p.next
    p.next = b
    p.bits[b] = temp
    p.available += 1
    return nothing
end

function _reset!(p::_BitPool)
    p.next = 0
    p.length = 0
    p.available = 0
end
