
struct Entity
    _id::UInt32
    _gen::UInt32
end

mutable struct _EntityPool
	entities::Vector{Entity}
	next::UInt32
	available::UInt32
end

function _EntityPool(initialCap::UInt32)
    v = Vector{Entity}()
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
    e = Entity(length(p.entities)+1, 0)
    push!(p.entities, e)
    return e
end

function _recycle(p::_EntityPool, e::Entity)
    if e._id < 1
        error("can't recycle reserved zero entity")
    end
    temp = p.next
    p.next = e._id
    p.entities[e._id] = Entity(temp, e._gen+1)
    p.available += 1
end

function _alive(p::_EntityPool, e::Entity)::Bool
    return e._gen == p.entities[e._id]._gen
end
