
struct _Archetype
    entities::Column{Entity}
    components::Vector{UInt8}  # Indices into the global ComponentStorage list
    mask::_Mask
end

function _Archetype()
    _Archetype(Column{Entity}(), Vector{UInt8}(), _Mask())
end

function _Archetype(mask::_Mask, components::UInt8...)
    _Archetype(Column{Entity}(), collect(components), mask)
end

function _add_entity!(arch::_Archetype, entity::Entity)::UInt32
    push!(arch.entities._data, entity)
    return length(arch.entities)
end