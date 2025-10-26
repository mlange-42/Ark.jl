
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
    storage.data[index] = _new_column(storage)
end

function _ensure_column_size!(storage::_ComponentStorage{C,S}, arch::UInt32, needed::UInt32) where {C,S<:StructArray{C}}
    col = storage.data[arch]
    if length(col._data) < needed
        resize!(col._data, needed)
    end
end

function _move_component_data!(s::_ComponentStorage{C,S}, old_arch::UInt32, new_arch::UInt32, row::UInt32) where {C,S<:StructArray{C}}
    old_vec = s.data[Int(old_arch)]
    new_vec = s.data[Int(new_arch)]
    push!(new_vec._data, old_vec[row])
    _swap_remove!(old_vec._data, row)
end

function _remove_component_data!(s::_ComponentStorage{C,S}, arch::UInt32, row::UInt32) where {C,S<:StructArray{C}}
    col = s.data[Int(arch)]
    _swap_remove!(col._data, row)
end

@generated function _structarray_prototype(::Type{C}) where {C}
    fnames = fieldnames(C)
    ftypes = C.types

    tuple_type_expr = Expr(:curly, :Tuple, [:(Vector{$(ftypes[i])}) for i in 1:length(fnames)]...)
    nt_type_expr = Expr(:curly, :NamedTuple,
        Expr(:tuple, map(QuoteNode, fnames)...),
        tuple_type_expr
    )
    value_expr = Expr(:tuple, [:(Vector{$(ftypes[i])}()) for i in 1:length(fnames)]...)

    return quote
        storage = convert($nt_type_expr, $value_expr)
        StructArray{C}(storage)
    end
end

function _structarray_prototype_type(::Type{C}) where {C}
    fnames = fieldnames(C)
    ftypes = C.types
    n = length(fnames)

    values = (; (fnames[i] => Vector{ftypes[i]}() for i in 1:n)...)

    sa = StructArray{C}(values)
    return typeof(sa)
end
