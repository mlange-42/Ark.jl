"""
    Entity

Entity identifier.
"""
struct Entity
    _id::UInt32
    _gen::UInt32

    Entity(id::UInt32, gen::UInt32) = new(id, gen)
end

function _new_entity(id::UInt32, gen::UInt32)
    Entity(id, gen)
end

function _new_entity(id::Int, gen::Int)
    Entity(UInt32(id), UInt32(gen))
end

struct _EntityIndex
    archetype::UInt32
    row::UInt32
end

mutable struct _EntityPool
    entities::Vector{Entity}
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
    p.next = p.entities[p.next]._id

    temp = p.entities[curr]
    p.entities[curr] = Entity(curr, temp._gen)

    p.available -= 1
    return p.entities[curr]
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
    return e._gen == p.entities[e._id]._gen
end
