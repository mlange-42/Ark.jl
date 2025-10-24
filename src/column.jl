
"""
    Column{C}

Archetype column storing one type of components.
Can be iterated, indexed and updated like a Vector.

Used in query iteration.
"""
struct Column{C,S<:StructArray{C}}
    _data::S
end

@generated function Column{C}() where {C}
    fnames = fieldnames(C)
    ftypes = C.types

    # Build Tuple type: Tuple{Vector{T1}, Vector{T2}, ...}
    tuple_type_expr = Expr(:curly, :Tuple, [:(Vector{$(ftypes[i])}) for i in 1:length(fnames)]...)

    # Build NamedTuple type: NamedTuple{(:x, :y), Tuple{...}}
    nt_type_expr = Expr(:curly, :NamedTuple,
        Expr(:tuple, map(QuoteNode, fnames)...),
        tuple_type_expr
    )

    # Build value tuple: (Vector{T1}(), Vector{T2}(), ...)
    value_expr = Expr(:tuple, [:(Vector{$(ftypes[i])}()) for i in 1:length(fnames)]...)

    return quote
        storage = convert($nt_type_expr, $value_expr)
        sa = StructArray{C}(storage)
        Column{C,typeof(sa)}(sa)
    end
end

function _new_column(::Type{C}) where {C}
    fnames = fieldnames(C)
    ftypes = C.types
    storage = NamedTuple{fnames}(ntuple(i -> Vector{ftypes[i]}(), length(fnames)))
    sa = StructArray{C}(storage)
    Column{C,typeof(sa)}(sa)
end

Base.@propagate_inbounds function Base.getindex(c::Column, i::Integer)
    return Base.getindex(c._data, i)
end

Base.@propagate_inbounds function Base.setindex!(c::Column, value, i::Integer)
    Base.setindex!(c._data, value, i)
end

function Base.length(c::Column)
    return length(c._data)
end

Base.eachindex(c::Column) = eachindex(c._data)
Base.enumerate(c::Column) = enumerate(c._data)
Base.iterate(c::Column) = iterate(c._data)
Base.iterate(c::Column, state) = iterate(c._data, state)

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
