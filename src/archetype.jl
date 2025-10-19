
struct _Archetype
    entities::Vector{Entity}
    components::Vector{UInt8}  # Indices into the global ComponentStorage list
    mask::_Mask
end

function _Archetype()
    _Archetype(Vector{Entity}(), Vector{UInt8}(), _Mask())
end

function _Archetype(mask::_Mask, components::UInt8...)
    _Archetype(Vector{Entity}(), collect(components), mask)
end

function _add_entity!(arch::_Archetype, entity::Entity)::UInt32
    push!(arch.entities, entity)
    return length(arch.entities)
end