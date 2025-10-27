
"""
    Column{C,S<:StructArray{C}}

Archetype column storing one type of components.
Can be iterated, indexed and updated like a Vector.

Used in query iteration.
"""
struct Column{C,S<:StructArray{C}} <: AbstractVector{C}
    _data::S
end

Base.@propagate_inbounds function Base.getindex(c::Column{C,S}, i::Integer) where {C,S<:StructArray{C}}
    return getindex(c._data, i)
end

Base.@propagate_inbounds function Base.setindex!(c::Column{C,S}, v::C, i::Integer) where {C,S<:StructArray{C}}
    setindex!(c._data, v, i)
end

Base.length(c::Column{C,S}) where {C,S<:StructArray{C}} = length(c._data)
Base.eachindex(c::Column{C,S}) where {C,S<:StructArray{C}} = eachindex(c._data)
Base.enumerate(c::Column{C,S}) where {C,S<:StructArray{C}} = enumerate(c._data)
Base.iterate(c::Column{C,S}) where {C,S<:StructArray{C}} = iterate(c._data)
Base.iterate(c::Column{C,S}, state) where {C,S<:StructArray{C}} = iterate(c._data, state)
Base.eltype(::Type{Column{C,S}}) where {C,S} = C
Base.IndexStyle(::Type{<:Column}) = IndexLinear()
Base.size(c::Column{C,S}) where {C,S<:StructArray{C}} = (length(c),)
Base.firstindex(c::Column{C,S}) where {C,S<:StructArray{C}} = firstindex(c._data)
Base.lastindex(c::Column{C,S}) where {C,S<:StructArray{C}} = lastindex(c._data)

# TODO: This is terribly inefficient. Make a type stable version.
unpack(col::StructArray) = StructArrays.components(col)

"""
    Entities

Archetype column for entities.
Can be iterated and indexed like a Vector.

Used in query iteration.
"""
struct Entities <: AbstractVector{Entity}
    _data::Vector{Entity}
    Entities() = new(Vector{Entity}())
end

function _new_entities_column()
    Entities()
end

Base.@propagate_inbounds function Base.getindex(c::Entities, i::Integer)
    getindex(c._data, i)
end
Base.length(c::Entities) = length(c._data)
Base.eachindex(c::Entities) = eachindex(c._data)
Base.enumerate(c::Entities) = enumerate(c._data)
Base.iterate(c::Entities) = iterate(c._data)
Base.iterate(c::Entities, state) = iterate(c._data, state)
Base.eltype(::Type{Entities}) = Entity
Base.IndexStyle(::Type{Entities}) = IndexLinear()
Base.size(c::Entities) = (length(c),)
Base.firstindex(c::Entities) = firstindex(c._data)
Base.lastindex(c::Entities) = lastindex(c._data)

# TODO: Re-enable this.
unpack(col::Entities) = col
