
struct _ComponentStorage{C,A<:AbstractArray{C,1}}
    data::Vector{A}
end

function _new_vector_storage(::Type{C}) where {C}
    _ComponentStorage{C,Vector{C}}([Vector{C}()])
end

function _new_struct_array_storage(::Type{C}) where {C}
    _ComponentStorage{C,_StructArray_type(C)}([_StructArray(C)])
end

function _get_component(s::_ComponentStorage{C,A}, arch::UInt32, row::UInt32) where {C,A<:AbstractArray}
    @inbounds col = s.data[arch]
    if length(col) == 0
        throw(ArgumentError(lazy"entity has no $C component"))
    end
    return @inbounds col[row]
end

function _set_component!(s::_ComponentStorage{C,A}, arch::UInt32, row::UInt32, value::C) where {C,A<:AbstractArray}
    @inbounds col = s.data[arch]
    if length(col) == 0
        throw(ArgumentError(lazy"entity has no $C component"))
    end
    return @inbounds col[row] = value
end

@generated function _add_column!(storage::_ComponentStorage{C,A}) where {C,A<:AbstractArray}
    if A <: _StructArray
        return quote
            push!(storage.data, _StructArray(C))
        end
    else
        return quote
            push!(storage.data, Vector{C}())
        end
    end
end

@generated function _assign_column!(storage::_ComponentStorage{C,A}, index::Int) where {C,A<:AbstractArray}
    if A <: _StructArray
        return quote
            storage.data[index] = _StructArray(C)
        end
    else
        return quote
            storage.data[index] = Vector{C}()
        end
    end
end

function _ensure_column_size!(storage::_ComponentStorage{C,A}, arch::UInt32, needed::Int) where {C,A<:AbstractArray}
    col = storage.data[arch]
    if length(col) < needed
        resize!(col, needed)
    end
end

function _move_component_data!(
    s::_ComponentStorage{C,A},
    old_arch::UInt32,
    new_arch::UInt32,
    row::UInt32,
) where {C,A<:AbstractArray}
    # TODO: this can probably be optimized for StructArray storage
    # by moving per component instead of unpacking/packing.
    old_vec = s.data[old_arch]
    new_vec = s.data[new_arch]
    push!(new_vec, old_vec[row])
    _swap_remove!(old_vec, row)
end

@generated function _copy_component_data!(
    s::_ComponentStorage{C,A},
    old_arch::UInt32,
    new_arch::UInt32,
    old_row::UInt32,
    new_row::UInt32,
    ::CP,
) where {C,A<:AbstractArray,CP<:Val}
    # TODO: this can probably be optimized for StructArray storage
    # by moving per component instead of unpacking/packing.
    exprs = []
    push!(exprs, :(old_vec = s.data[old_arch]))
    push!(exprs, :(new_vec = s.data[new_arch]))

    if CP === Val{:ref} || (isbitstype(C) && !ismutabletype(C))
        # no copy required for immutable isbits
        push!(exprs, :(new_vec[new_row] = old_vec[old_row]))
    elseif CP === Val{:copy} || isbitstype(C)
        # no deep copy required for (mutable) isbits
        push!(exprs, :(new_vec[new_row] = copy(old_vec[old_row])))
    elseif CP === Val{:deepcopy}
        push!(exprs, :(new_vec[new_row] = deepcopy(old_vec[old_row])))
    else
        mode = CP.parameters[1]
        throw(ArgumentError("'$mode' is not a valid copy mode, must be :ref, :copy or :deepcopy"))
    end

    push!(exprs, Expr(:return, :nothing))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

function _remove_component_data!(s::_ComponentStorage{C,A}, arch::UInt32, row::UInt32) where {C,A<:AbstractArray}
    col = s.data[arch]
    _swap_remove!(col, row)
end
