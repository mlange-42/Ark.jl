
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
