
@generated function _FieldsViewable_type(::Type{A}) where {A<:AbstractArray{T,N}} where {T,N}
    return :(FieldViewable{$T,$N,$A})
end

"""
    unpack(a::FieldViewable)

Unpacks the components (i.e. field vectors) of a [VectorStorage](@ref) column returned from a [Query](@ref).
See also [@unpack](@ref).
"""
@generated function unpack(v::FieldViewable{T}) where {T}
    props = fieldnames(T)
    exprs = [:(FieldView{$(QuoteNode(p))}(v)) for p in props]
    return :(tuple($(exprs...)))
end

unpack(a::SubArray) = a
