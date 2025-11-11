import Base.Broadcast: BroadcastStyle, AbstractArrayStyle
import Base.Broadcast: copyto!

struct FieldsView{C,S<:SubArray,CS<:NamedTuple,N} <: AbstractArray{C,1}
    _subarray::S
    _components::CS
end

@generated function _new_fields_view(vec::A) where {A<:SubArray{C}} where {C}
    if !isbitstype(C)
        return quote
            throw(ArgumentError("non-isbits type $(C) not supported by FieldsView"))
        end
    end

    names = fieldnames(C)
    types = fieldtypes(C)

    field_types = [
        :(FieldView{$t,C,Val{$(QuoteNode(n))},A})
        for (n, t) in zip(names, types)
    ]
    nt_type = :(NamedTuple{($(map(QuoteNode, names)...),),Tuple{$(field_types...)}})

    field_exprs = [
        :($(n) = _new_field_subarray(vec, Val($(QuoteNode(n)))))
        for n in names
    ]

    return quote
        FieldsView{C,A,$nt_type,$(length(names))}(
            vec,
            (; $(field_exprs...)),
        )
    end
end

@generated function _FieldsView_type(::Type{A}) where {A<:SubArray{C}} where {C}
    names = fieldnames(C)
    types = fieldtypes(C)

    field_types = [
        :(FieldView{$t,C,Val{$(QuoteNode(n))},A})
        for (n, t) in zip(names, types)
    ]
    nt_type = :(NamedTuple{($(map(QuoteNode, names)...),),Tuple{$(field_types...)}})

    return quote
        FieldsView{C,A,$nt_type,$(length(names))}
    end
end

@generated function Base.getproperty(a::FieldsView{C}, name::Symbol) where {C}
    component_names = fieldnames(C)
    cases = [
        :(name === $(QuoteNode(n)) && return a._components.$n) for n in component_names
    ]
    fallback = :(return getfield(a, name))
    return Expr(:block, cases..., fallback)
end

Base.@propagate_inbounds Base.getindex(a::FieldsView, idx::Integer) = Base.getindex(a._subarray, idx)
Base.@propagate_inbounds Base.setindex!(a::FieldsView, v, idx::Integer) = Base.setindex!(a._subarray, v, idx)
Base.@propagate_inbounds Base.iterate(a::FieldsView) = Base.iterate(a._subarray)

Base.@propagate_inbounds function Base.iterate(a::FieldsView, i::Int)
    Base.iterate(a._subarray, i)
end

Base.size(a::FieldsView) = size(a._subarray)
Base.length(a::FieldsView) = length(a._subarray)
Base.eachindex(a::FieldsView) = Base.eachindex(a._subarray)
Base.firstindex(a::FieldsView) = Base.firstindex(a._subarray)
Base.lastindex(a::FieldsView) = Base.lastindex(a._subarray)

Base.eltype(::Type{<:FieldsView{C}}) where {C} = C
Base.IndexStyle(::Type{<:FieldsView}) = IndexLinear()

"""
    unpack(a::FieldsView)

Unpacks the components (i.e. field vectors) of a [VectorStorage](@ref) column returned from a [Query](@ref).
See also [@unpack](@ref).
"""
unpack(a::FieldsView) = a._components

struct FieldView{C,T,F,A<:SubArray{T}} <: AbstractArray{C,1}
    _data::A
    _offset::Int
end

@generated function _new_field_subarray(data::A, ::Val{F}) where {A<:SubArray{T},F} where {T}
    ftype = fieldtype(T, F)
    idx = Base.fieldindex(T, F)
    offset = fieldoffset(T, idx)
    quote
        FieldView{$(ftype),T,Val{$(QuoteNode(F))},A}(data, $(offset))
    end
end

Base.@propagate_inbounds @inline function Base.getindex(
    a::FieldView{C,T,Val{F},A},
    i::Integer,
) where {C,T,F,A<:SubArray{T}}
    @boundscheck checkbounds(a, i)
    GC.@preserve a begin
        ptr::Ptr{C} = pointer(a._data, i) + a._offset
        unsafe_load(ptr)
    end
end

Base.@propagate_inbounds @inline function Base.setindex!(
    a::FieldView{C,T,Val{F},A},
    x,
    i::Integer,
) where {C,T,F,A<:SubArray{T}}
    @boundscheck checkbounds(a, i)
    GC.@preserve a begin
        ptr::Ptr{C} = pointer(a._data, i) + a._offset
        unsafe_store!(ptr, convert(C, x))
    end
end

function Base.iterate(a::FieldView)
    length(a) == 0 && return nothing
    return (@inbounds a[1]), 2
end

function Base.iterate(a::FieldView, i::Int)
    i > length(a) && return nothing
    return (@inbounds a[i]), i + 1
end

Base.length(a::FieldView) = Base.length(a._data)
Base.size(a::FieldView) = Base.size(a._data)
Base.eachindex(a::FieldView) = Base.eachindex(a._data)
Base.firstindex(a::FieldView) = Base.firstindex(a._data)
Base.lastindex(a::FieldView) = Base.lastindex(a._data)

Base.eltype(::Type{<:FieldView{C,T}}) where {C,T} = C
Base.IndexStyle(::Type{<:FieldView{C,T,F,A}}) where {C,T,F,A} = IndexStyle(A)

Base.Broadcast.BroadcastStyle(::Type{<:FieldView{C,T,F,A}}) where {C,T,F,A} = Base.Broadcast.BroadcastStyle(A)

@inline function Base.Broadcast.copyto!(
    dest::FieldView,
    bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle},
)
    bc_inst = Broadcast.instantiate(bc)
    @assert axes(dest) == axes(bc_inst)
    @inbounds @simd for i in eachindex(dest)
        dest[i] = bc_inst[i]
    end
    return dest
end

Base.parent(a::FieldView) = a._data
Base.similar(a::FieldView, ::Type{T}, dims::Dims) where {T} = similar(a._data, T, dims)
Base.axes(a::FieldView) = axes(a._data)
Base.broadcastable(a::FieldView) = a
Base.strides(a::FieldView) = strides(a._data)
Base.pointer(a::FieldView) = pointer(a._data)
Base.pointer(a::FieldView, i::Integer) = pointer(a._data, i)

unpack(a::SubArray) = a

function Base.show(io::IO, a::FieldView{C,T}) where {C,T}
    print(io, "$(length(a))-element FieldView() with eltype $(_format_type(C))")
    if length(a) == 0
        return
    end
    if length(a) < 12
        elems = join(a, ", ")
        print(io, "\n [$elems]\n")
    else
        first = join(a[1:5], ", ")
        last = join(a[end-4:end], ", ")
        print(io, "\n [$first, …, $last]\n")
    end
end
