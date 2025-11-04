
struct _StructArray{C,CS<:NamedTuple,N} <: AbstractArray{C,1}
    components::CS
end

function _StructArray(tp::Type{C}) where {C}
    _StructArray_from_type(tp)
end

@generated function _StructArray_from_type(::Type{C}) where {C}
    names = fieldnames(C)
    types = fieldtypes(C)
    num_fields = length(types)

    nt_type = :(NamedTuple{($(map(QuoteNode, names)...),),Tuple{$(map(t -> :(Vector{$t}), types)...)}})
    kv_exprs = [:($name = Vector{$t}()) for (name, t) in zip(names, types)]

    return quote
        _StructArray{C,$nt_type,$num_fields}((; $(kv_exprs...)))
    end
end

@generated function Base.push!(sa::_StructArray{C}, c::C) where {C}
    names = fieldnames(C)
    push_exprs = [
        :(push!(sa.components.$name, c.$name)) for name in names
    ]
    return Expr(:block, push_exprs..., :(sa))
end

@generated function Base.getindex(sa::_StructArray{C}, i::Int) where {C}
    names = fieldnames(C)
    field_exprs = [
        :($(name) = sa.components.$name[i]) for name in names
    ]
    return Expr(:block, Expr(:call, C, field_exprs...))
end

@generated function Base.setindex!(sa::_StructArray{C}, c::C, i::Int) where {C}
    names = fieldnames(C)
    set_exprs = [
        :(sa.components.$name[i] = c.$name) for name in names
    ]
    return Expr(:block, set_exprs..., :(sa))
end
