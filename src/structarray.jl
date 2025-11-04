
mutable struct _StructArray{C,CS<:NamedTuple,N} <: AbstractArray{C,1}
    components::CS
    length::Int
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
        _StructArray{C,$nt_type,$num_fields}((; $(kv_exprs...)), 0)
    end
end

@generated function _StructArray_type(::Type{C}) where {C}
    names = fieldnames(C)
    types = fieldtypes(C)
    num_fields = length(types)

    nt_type = :(NamedTuple{($(map(QuoteNode, names)...),),Tuple{$(map(t -> :(Vector{$t}), types)...)}})

    return quote
        _StructArray{C,$nt_type,$num_fields}
    end
end

@generated function Base.getproperty(sa::_StructArray{C}, name::Symbol) where {C}
    # TODO: do we need this? Seems not called when doing `sa.components`.
    #if name == :components || name == :length
    #    return :(getfield(sa, name))
    #end
    component_names = fieldnames(C)
    cases = [
        :(name === $(QuoteNode(n)) && return sa.components.$n) for n in component_names
    ]
    fallback = :(return getfield(sa, name))
    return Expr(:block, cases..., fallback)
end

@generated function Base.resize!(sa::_StructArray{C}, n::Int) where {C}
    names = fieldnames(C)
    resize_exprs = [
        :(resize!(sa.components.$name, n)) for name in names
    ]
    inc_length = :(sa.length = n)
    return Expr(:block, resize_exprs..., inc_length, :(sa))
end

@generated function Base.push!(sa::_StructArray{C}, c::C) where {C}
    names = fieldnames(C)
    push_exprs = [
        :(push!(sa.components.$name, c.$name)) for name in names
    ]
    inc_length = :(sa.length += 1)
    return Expr(:block, push_exprs..., inc_length, :(sa))
end

@generated function Base.pop!(sa::_StructArray{C}) where {C}
    names = fieldnames(C)
    pop_exprs = [
        :(pop!(sa.components.$name)) for name in names
    ]
    dec_length = :(sa.length -= 1)
    return Expr(:block, pop_exprs..., dec_length, :(sa))
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

function Base.iterate(sa::_StructArray{C}) where {C}
    sa.length == 0 && return nothing
    return sa[1], 2
end

function Base.iterate(sa::_StructArray{C}, i::Int) where {C}
    i > sa.length && return nothing
    return sa[i], i + 1
end

Base.length(sa::_StructArray) = sa.length
Base.size(sa::_StructArray) = (sa.length,)
Base.eachindex(sa::_StructArray) = 1:sa.length
Base.eltype(::Type{<:_StructArray{C}}) where {C} = C
Base.IndexStyle(::Type{<:_StructArray}) = IndexLinear()

function Base.firstindex(sa::_StructArray)
    # Do not simplify to this, as it is then not covered by the tests for some reason:
    # Base.firstindex(sa::_StructArray) = 1
    return 1
end

Base.lastindex(sa::_StructArray) = sa.length
