
struct Entity
    _id::UInt32
    _gen::UInt32
end

mutable struct _EntityPool
	entities::Vector{Entity}
	next::UInt32
	available::UInt32
	reserved::UInt32
end

function _EntityPool(initialCap::UInt32, reserved::UInt32)
    v = Vector{Entity}()
    sizehint!(v, initialCap+reserved)
    for i in 1:reserved
        push!(v, Entity(i, typemax(UInt32)))
    end

    return _EntityPool(v, 0, 0, reserved)
end
