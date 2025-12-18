
mutable struct _EntityPool
    const entities::Vector{Entity}
    next::Int
    available::Int
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
    temp = p.entities[curr]

    p.next = temp._id
    entity = Entity(curr % UInt32, temp._gen)
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
    p.entities[e._id] = _new_entity(temp % UInt32, e._gen + UInt32(1))
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
    bits::UInt64
end

function _BitPool()
    return _BitPool(0)
end

function _get_bit(p::_BitPool)::Int
    if p.bits == typemax(UInt64)
        throw(
            InvalidStateException(
                string("run out of the maximum of 64 bits. ",
                    "This is likely caused by unclosed queries that lock the world. ",
                    "Make sure that all queries finish their iteration or are closed manually"),
                :locks_exhausted,
            ),
        )
    end
    b = trailing_zeros(~p.bits)
    p.bits |= UInt64(1) << b
    return b + 1
end

function _recycle(p::_BitPool, b::Int)
    p.bits &= ~(UInt64(1) << (b - 1))
    return nothing
end

function _reset!(p::_BitPool)
    p.bits = 0
end
