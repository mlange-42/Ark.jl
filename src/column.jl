
"""
    _Column{C}

Archetype column storing one type of components.
Can be iterated, indexed and updated like a Vector.

Used in query iteration.
"""
struct _Column{C} <: AbstractVector{C}
    _data::Vector{C}
    _Column{C}() where {C} = new{C}(Vector{C}())
end

function _new_column(::Type{C}) where {C}
    _Column{C}()
end

Base.@propagate_inbounds function Base.getindex(c::_Column, i::Integer)
    Base.getindex(c._data, i)
end
Base.@propagate_inbounds function Base.setindex!(c::_Column, value, i::Integer)
    Base.setindex!(c._data, value, i)
end
Base.length(c::_Column) = length(c._data)
Base.eachindex(c::_Column) = eachindex(c._data)
Base.enumerate(c::_Column) = enumerate(c._data)
Base.iterate(c::_Column) = iterate(c._data)
Base.iterate(c::_Column, state) = iterate(c._data, state)
Base.eltype(::Type{_Column{C}}) where {C} = C
Base.IndexStyle(::Type{<:_Column}) = IndexLinear()
Base.size(c::_Column) = (length(c),)
Base.firstindex(c::_Column) = firstindex(c._data)
Base.lastindex(c::_Column) = lastindex(c._data)

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
