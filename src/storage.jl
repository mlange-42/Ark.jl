
struct _ComponentStorage{C,S<:StructArray{C}}
    prototype::S
    data::Vector{Union{Nothing,Column{C,S}}}
end

function _make_component_storage(::Type{C}, archetypes::Int, prototype::S) where {C,S}
    data = Vector{Union{Nothing,Column{C,S}}}(nothing, archetypes)
    _ComponentStorage{C,S}(prototype, data)
end

function _new_column(storage::_ComponentStorage{C,S}) where {C,S<:StructArray{C}}
    sa = similar(storage.prototype, 0)
    Column{C,S}(sa)
end

function _assign_column!(storage::_ComponentStorage{C,S}, index::UInt32) where {C,S<:StructArray{C}}
    storage.data[Int(index)] = _new_column(storage)
end

function _ensure_column_size!(storage::_ComponentStorage{C,S}, arch::UInt32, needed::UInt32) where {C,S<:StructArray{C}}
    col = storage.data[Int(arch)]
    if length(col._data) < needed
        resize!(col._data, needed)
    end
end

function _move_component_data!(s::_ComponentStorage{C,S}, old_arch::UInt32, new_arch::UInt32, row::UInt32) where {C,S<:StructArray{C}}
    old_vec = s.data[Int(old_arch)]
    new_vec = s.data[Int(new_arch)]
    push!(new_vec._data, old_vec[Int(row)])
    _swap_remove!(old_vec._data, row)
end

function _remove_component_data!(s::_ComponentStorage{C,S}, arch::UInt32, row::UInt32) where {C,S<:StructArray{C}}
    col = s.data[Int(arch)]
    _swap_remove!(col._data, row)
end

@generated function _structarray_prototype(::Type{C}) where {C}
    fnames = fieldnames(C)
    ftypes = fieldtypes(C)
    m = length(fnames)

    # value expressions: Vector{T}() for each field
    value_exprs = [:(Vector{$(QuoteNode(ftypes[i]))}()) for i in 1:m]
    value_tuple_expr = Expr(:tuple, value_exprs...)

    # names tuple: (:x, :y, ...)
    names_tuple = Expr(:tuple, map(QuoteNode, fnames)...)

    # NamedTuple type expression: NamedTuple{(:x,:y)}
    nt_type_ctor = Expr(:curly, :NamedTuple, names_tuple)

    # construct NamedTuple by calling NamedTuple{names}((v1, v2, ...))
    nt_construct = Expr(:call, nt_type_ctor, value_tuple_expr)

    return quote
        storage = $(nt_construct)
        StructArray{C}(storage)
    end
end

@generated function _structarray_prototype_type(::Type{C}) where {C}
    fnames = fieldnames(C)
    ftypes = fieldtypes(C)
    n = length(fnames)

    # build value tuple expr: (Vector{T1}(), Vector{T2}(), ...)
    value_exprs = [:(Vector{$(QuoteNode(ftypes[i]))}()) for i in 1:n]
    value_tuple_expr = Expr(:tuple, value_exprs...)

    # build names tuple expr: (:f1, :f2, ...)
    names_tuple_expr = Expr(:tuple, map(QuoteNode, fnames)...)

    # build NamedTuple constructor expression: NamedTuple{(:f1,:f2,...)}((v1,v2,...))
    nt_type_ctor_expr = Expr(:curly, :NamedTuple, names_tuple_expr)
    nt_construct_expr = Expr(:call, nt_type_ctor_expr, value_tuple_expr)

    return quote
        storage = $(nt_construct_expr)   # concrete NamedTuple of Vector{Ti}
        sa = StructArray{C}(storage)
        return typeof(sa)
    end
end
