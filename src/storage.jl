
struct _ComponentStorage{C,A<:AbstractArray{C,1}}
    data::Vector{A}
end

function _ComponentStorage{C,A}() where {C,A<:AbstractArray}
    _ComponentStorage{C,Vector{C}}([Vector{C}()])
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

function _add_column!(storage::_ComponentStorage{C,A}) where {C,A<:AbstractArray}
    push!(storage.data, Vector{C}())
end

function _assign_column!(storage::_ComponentStorage{C,A}, index::UInt32) where {C,A<:AbstractArray}
    storage.data[index] = Vector{C}()
end

function _ensure_column_size!(storage::_ComponentStorage, arch::UInt32, needed::UInt32)
    col = storage.data[arch]
    if length(col) < needed
        resize!(col, needed)
    end
end

function _move_component_data!(s::_ComponentStorage, old_arch::UInt32, new_arch::UInt32, row::UInt32)
    old_vec = s.data[old_arch]
    new_vec = s.data[new_arch]
    push!(new_vec, old_vec[row])
    _swap_remove!(old_vec, row)
end

function _remove_component_data!(s::_ComponentStorage, arch::UInt32, row::UInt32)
    col = s.data[arch]
    _swap_remove!(col, row)
end
