
mutable struct _Archetype
    entities::Vector{Entity}
    component_indices::Vector{UInt8}  # Indices into the global ComponentStorage list
    mask::_Mask
end

function _Archetype()
    _Archetype(Vector{Entity}(), Vector{UInt8}(), _Mask())
end

function _Archetype(components::UInt8...)
    _Archetype(Vector{Entity}(), collect(components), _Mask(components...))
end
