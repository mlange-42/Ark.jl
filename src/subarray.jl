import Base.Broadcast: BroadcastStyle, AbstractArrayStyle
import Base.Broadcast: copyto!

struct FieldsView{C,S<:SubArray,CS<:NamedTuple,N} <: AbstractArray{C,1}
    _subarray::S
    _components::CS
end

@generated function FieldsView(vec::A) where {A<:SubArray{C}} where {C}
    if !isbitstype(C)
        return quote
            throw(ArgumentError("non-isbits type $(C) not supported by FieldsView"))
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
        FieldsView{C,A,$nt_type,$(length(names))}(
            vec,
            (; $(field_exprs...)),
        )
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
Base.@propagate_inbounds Base.iterate(a::FieldsView{C}) where {C} = Base.iterate(a._subarray)

Base.@propagate_inbounds function Base.iterate(a::FieldsView{C}, i::Int) where {C}
    Base.iterate(a._subarray, i)
end

Base.size(a::FieldsView) = size(a._subarray)
Base.length(a::FieldsView) = length(a._subarray)
Base.eachindex(a::FieldsView) = Base.eachindex(a._subarray)
Base.firstindex(a::FieldsView) = Base.firstindex(a._subarray)
Base.lastindex(a::FieldsView) = Base.lastindex(a._subarray)

Base.eltype(::Type{<:FieldsView{C}}) where {C} = C
Base.IndexStyle(::Type{<:FieldsView}) = IndexLinear()

unpack(a::FieldsView) = a._components

struct FieldSubArray{C,T,F,A<:SubArray{T}} <: AbstractArray{C,1}
    _data::A
    _field::F
    _ptr::Ptr{UInt8}
end

@generated function _new_field_subarray(
    data::A,
    ::Val{F},
) where {A<:SubArray{T},F} where {T}
    ftype = fieldtype(T, F)
    quote
        FieldSubArray{$(ftype),T,Val{F},A}(data, Val(F), Base.unsafe_convert(Ptr{UInt8}, pointer(data)))
    end
end

Base.@propagate_inbounds @inline @generated function Base.getindex(
    a::FieldSubArray{C,T,Val{F},A},
    i::Int,
) where {C,T,F,A<:SubArray{T}}
    quote
        a._data[i].$(F)
    end
end

Base.@propagate_inbounds @inline @generated function Base.setindex!(
    a::FieldSubArray{C,T,Val{F},A},
    v,
    i::Int,
) where {C,T,F,A<:SubArray{T}}
    idx = Base.fieldindex(T, F)
    offset = fieldoffset(T, idx)
    size = sizeof(T)
    return quote
        @boundscheck checkbounds(a, i)
        GC.@preserve a begin
            raw = Ptr{C}(a._ptr + (i - 1) * $size + $(offset))
            unsafe_store!(raw, v)
        end
        nothing
    end
end

function Base.iterate(a::FieldSubArray{C}) where {C}
    length(a) == 0 && return nothing
    return (@inbounds a[1]), 2
end

function Base.iterate(a::FieldSubArray{C}, i::Int) where {C}
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

function Base.Broadcast.copyto!(
    dest::FieldSubArray{C,T,F,A},
    bc::Base.Broadcast.Broadcasted{S},
) where {C,T,F,A,S<:Base.Broadcast.DefaultArrayStyle}
    bc_inst = Broadcast.instantiate(bc)
    @assert axes(dest) == axes(bc_inst)
    @inbounds @simd for i in eachindex(dest)
        dest[i] = bc_inst[i]
    end
    return dest
end

Base.similar(a::FieldSubArray{C}, ::Type{C}, dims::Dims) where {C} = similar(a._data, C, dims)

unpack(a::SubArray) = a
