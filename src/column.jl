
"""
    Column{C}

Archetype column storing one type of components.
Can be iterated, indexed and updated like a Vector.

Used in query iteration.
"""
struct Column{C} <: AbstractVector{C}
    _data::Vector{C}

    function Column{C}(capacity::UInt32) where {C}
        vec = Vector{C}()
        sizehint!(vec, capacity)
        new(vec)
    end
end

function _new_column(::Type{C}, capacity::UInt32) where {C}
    Column{C}(capacity)
end

Base.@propagate_inbounds function Base.getindex(c::Column, i::Integer)
    return Base.getindex(c._data, i)
end

Base.@propagate_inbounds function Base.setindex!(c::Column, value, i::Integer)
    Base.setindex!(c._data, value, i)
end

Base.length(c::Column) = length(c._data)
Base.eachindex(c::Column) = eachindex(c._data)
Base.enumerate(c::Column) = enumerate(c._data)
Base.iterate(c::Column) = iterate(c._data)
Base.iterate(c::Column, state) = iterate(c._data, state)
Base.eltype(::Type{Column{C}}) where {C} = C
Base.IndexStyle(::Type{<:Column}) = IndexLinear()
Base.size(c::Column) = (length(c),)

"""
    Entities

Archetype column for entities.
Can be iterated and indexed like a Vector.

Used in query iteration.
"""
struct Entities <: AbstractVector{Entity}
    _data::Vector{Entity}

    function Entities(capacity::UInt32)
        vec = Vector{Entity}()
        sizehint!(vec, capacity)
        new(vec)
    end
end

function _new_entities_column()
    Entities(UInt32(1024))
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
Base.IndexStyle(::Type{<:Entities}) = IndexLinear()
Base.size(c::Entities) = (length(c),)
