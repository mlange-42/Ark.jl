
"""
    Column{C}

Archetype column storing one type of components.
Can be iterated, indexed and updated like a Vector.

Used in query iteration.
"""
struct Column{C,S<:StructArray{C}}
    _data::S
end

function _new_column(::Type{C}) where {C}
    fnames = fieldnames(C)
    ftypes = C.types
    storage = NamedTuple{fnames}(ntuple(i -> Vector{ftypes[i]}(), length(fnames)))
    sa = StructArray{C}(storage)
    Column{C,typeof(sa)}(sa)
end

Base.@propagate_inbounds function Base.getindex(c::Column{C,S}, i::Integer) where {C,S<:StructArray{C}}
    return getindex(c._data, i)
end

Base.@propagate_inbounds function Base.setindex!(c::Column{C,S}, v::C, i::Integer) where {C,S<:StructArray{C}}
    setindex!(c._data, v, i)
end

function Base.length(c::Column)
    return length(c._data)
end

Base.eachindex(c::Column{C,S}) where {C,S<:StructArray{C}} = eachindex(c._data)
Base.iterate(c::Column{C,S}) where {C,S<:StructArray{C}} = iterate(c._data)
Base.iterate(c::Column{C,S}, st) where {C,S<:StructArray{C}} = iterate(c._data, st)
Base.enumerate(c::Column{C,S}) where {C,S<:StructArray{C}} = enumerate(c._data)

unpack(col::StructArray) = StructArrays.components(col)
unpack(col::Column) = unpack(col._data)

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

Base.@propagate_inbounds function Base.getindex(c::Entities, i::Integer)
    getindex(c._data, i)
end

function Base.length(c::Entities)
    return length(c._data)
end

Base.eachindex(c::Entities) = eachindex(c._data)
Base.enumerate(c::Entities) = enumerate(c._data)
Base.iterate(c::Entities) = iterate(c._data)
Base.iterate(c::Entities, state) = iterate(c._data, state)

unpack(col::Entities) = col
