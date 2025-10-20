"""
    Entity

Entity identifier.
"""
struct Entity
    _id::UInt32
    _gen::UInt32

    Entity(id::UInt32, gen::UInt32) = new(id, gen)
end

"""
    is_zero(entity::Entity)::Bool

Returns whether an [`Entity`](@ref) is the zero entity.
"""
function is_zero(entity::Entity)::Bool
    return entity._id == 1
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
