
include("mask.jl")
include("entity.jl")

mutable struct _Archetype
    entities::Vector{Entity}
    component_indices::Vector{UInt8}  # Indices into the global ComponentStorage list
    mask::_Mask
end

function _Archetype()
    _Archetype(Vector{Entity}(), Vector{UInt8}(), _Mask())
end

function _Archetype(components::UInt8...)
    _Archetype(Vector{Entity}(), components, _Mask(components))
end
