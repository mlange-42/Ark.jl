import Base.Broadcast: BroadcastStyle, AbstractArrayStyle
import Base.Broadcast: copyto!

struct _FieldsView{C,S<:SubArray,CS<:NamedTuple,N} <: AbstractArray{C,1}
    _subarray::S
    _components::CS
end

@generated function _FieldsView(vec::A) where {A<:SubArray{C}} where {C}
    if !isbitstype(C)
        return quote
            throw(ArgumentError("non-isbits type $(C) not supported by _FieldsView"))
        end
    end

    names = fieldnames(C)
    types = fieldtypes(C)

    field_types = [
        :(FieldSubArray{$t,C,Val{$(QuoteNode(n))},A})
        for (n, t) in zip(names, types)
    ]
    nt_type = :(NamedTuple{($(map(QuoteNode, names)...),),Tuple{$(field_types...)}})

    field_exprs = [
        :($(n) = _new_field_subarray(vec, Val($(QuoteNode(n)))))
        for n in names
    ]

    return quote
        _FieldsView{C,A,$nt_type,$(length(names))}(
            vec,
            (; $(field_exprs...)),
        )
    end
end

@generated function Base.getproperty(a::_FieldsView{C}, name::Symbol) where {C}
    component_names = fieldnames(C)
    cases = [
        :(name === $(QuoteNode(n)) && return a._components.$n) for n in component_names
    ]
    fallback = :(return getfield(a, name))
    return Expr(:block, cases..., fallback)
end

Base.@propagate_inbounds Base.getindex(a::_FieldsView, idx::Integer) = Base.getindex(a._subarray, idx)
Base.@propagate_inbounds Base.setindex!(a::_FieldsView, v, idx::Integer) = Base.setindex!(a._subarray, v, idx)
Base.@propagate_inbounds Base.iterate(a::_FieldsView) = Base.iterate(a._subarray)

Base.@propagate_inbounds function Base.iterate(a::_FieldsView, i::Int)
    Base.iterate(a._subarray, i)
end

Base.size(a::_FieldsView) = size(a._subarray)
Base.length(a::_FieldsView) = length(a._subarray)
Base.eachindex(a::_FieldsView) = Base.eachindex(a._subarray)
Base.firstindex(a::_FieldsView) = Base.firstindex(a._subarray)
Base.lastindex(a::_FieldsView) = Base.lastindex(a._subarray)

Base.eltype(::Type{<:_FieldsView{C}}) where {C} = C
Base.IndexStyle(::Type{<:_FieldsView}) = IndexLinear()

struct FieldSubArray{C,T,F,A<:SubArray{T}} <: AbstractArray{C,1}
    _data::A
    _offset::Int
end

function _new_field_subarray(data::A, ::Val{F}) where {A<:SubArray{T},F} where {T}
    ftype = fieldtype(T, F)
    idx = Base.fieldindex(T, F)
    offset = fieldoffset(T, idx)
    FieldSubArray{ftype,T,Val{F},A}(data, offset)
end

Base.@propagate_inbounds @inline function Base.getindex(
    a::FieldSubArray{C,T,Val{F},A},
    i::Integer,
) where {C,T,F,A<:SubArray{T}}
    @boundscheck checkbounds(a, i)
    GC.@preserve a begin
        ptr::Ptr{C} = pointer(a._data, i) + a._offset
        unsafe_load(ptr)::C
    end
end

Base.@propagate_inbounds @inline function Base.setindex!(
    a::FieldSubArray{C,T,Val{F},A},
    x,
    i::Integer,
) where {C,T,F,A<:SubArray{T}}
    @boundscheck checkbounds(a, i)
    GC.@preserve a begin
        ptr::Ptr{C} = pointer(a._data, i) + a._offset
        unsafe_store!(ptr, convert(C, x)::C)
    end
end

function Base.iterate(a::FieldSubArray)
    length(a) == 0 && return nothing
    return (@inbounds a[1]), 2
end

function Base.iterate(a::FieldSubArray, i::Int)
    i > length(a) && return nothing
    return (@inbounds a[i]), i + 1
end

Base.length(a::FieldSubArray) = Base.length(a._data)
Base.size(a::FieldSubArray) = Base.size(a._data)
Base.eachindex(a::FieldSubArray) = Base.eachindex(a._data)
Base.firstindex(a::FieldSubArray) = Base.firstindex(a._data)
Base.lastindex(a::FieldSubArray) = Base.lastindex(a._data)

Base.eltype(::Type{<:FieldSubArray{C,T}}) where {C,T} = C
Base.IndexStyle(::Type{<:FieldSubArray{C,T,F,A}}) where {C,T,F,A} = IndexStyle(A)

Base.Broadcast.BroadcastStyle(::Type{<:FieldSubArray{C,T,F,A}}) where {C,T,F,A} = Base.Broadcast.BroadcastStyle(A)

@inline function Base.Broadcast.copyto!(
    dest::FieldSubArray, 
    bc::Base.Broadcast.Broadcasted{<:Base.Broadcast.DefaultArrayStyle},
)
    bc_inst = Broadcast.instantiate(bc)
    @assert axes(dest) == axes(bc_inst)
    @inbounds @simd for i in eachindex(dest)
        dest[i] = bc_inst[i]
    end
    return dest
end

Base.parent(a::FieldSubArray) = a._data
Base.similar(a::FieldSubArray, ::Type{T}, dims::Dims) where {T} = similar(a._data, T, dims)
Base.axes(a::FieldSubArray) = axes(a._data)
Base.broadcastable(a::FieldSubArray) = a
Base.strides(a::FieldSubArray) = strides(a._data)
Base.pointer(a::FieldSubArray) = pointer(a._data)
Base.pointer(a::FieldSubArray, i::Integer) = pointer(a._data, i)

"""
    unpack(a::SubArray)

Unpacks the components (i.e. field vectors) of a [VectorComponent](@ref) column returned from a [Query](@ref).
See also [@unpack](@ref).
"""
unpack(a::SubArray) = _FieldsView(a)._components
