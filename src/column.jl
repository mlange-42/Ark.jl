
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

"""
    Entities

Archetype column for entities.
Can be iterated and indexed like a Vector.

Used in query iteration.
"""
struct Entities
    _data::Vector{Entity}

    Entities() = new(Vector{Entity}())
end

function _new_entities_column()
    Entities()
end

function Base.getindex(c::Entities, i::Integer)
    return c._data[i]
end

function Base.length(c::Entities)
    return length(c._data)
end

Base.eachindex(c::Entities) = eachindex(c._data)
Base.enumerate(c::Entities) = enumerate(c._data)
Base.iterate(c::Entities) = iterate(c._data)
Base.iterate(c::Entities, state) = iterate(c._data, state)
