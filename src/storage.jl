
"""
    Column{C}

Archetype column storing one type of components.
Can be iterated, indexed and updated like a Vector.

Used in query iteration.
"""
struct Column{C}
    _data::Vector{C}

    Column{C}() where {C} = new(Vector{C}())
end

function _new_column(::Type{C}) where {C}
    Column{C}()
end

struct _ComponentStorage{C}
    data::Vector{Union{Nothing,Column{C}}}  # Outer Vec: one per archetype
end

function _ComponentStorage{C}() where C
    _ComponentStorage{C}(Vector{Union{Nothing,Column{C}}}())
end

function _ComponentStorage{C}(archetypes::Int) where C
    _ComponentStorage{C}(Vector{Union{Nothing,Column{C}}}(nothing, archetypes))
end

function Base.getindex(c::Column, i::Integer)
    return c._data[i]
end

function Base.setindex!(c::Column, value, i::Integer)
    c._data[i] = value
end

function Base.length(c::Column)
    return length(c._data)
end

Base.eachindex(c::Column) = eachindex(c._data)
Base.enumerate(c::Column) = enumerate(c._data)
Base.iterate(c::Column) = iterate(c._data)
Base.iterate(c::Column, state) = iterate(c._data, state)