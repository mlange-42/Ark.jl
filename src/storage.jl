
struct _ComponentStorage{C}
    data::Vector{Vector{C}}
end

function _ComponentStorage{C}(archetypes::Int) where C
    _ComponentStorage{C}(fill(Vector{C}(), archetypes))
end

function _get_component(s::_ComponentStorage{C}, arch::UInt32, row::UInt32) where C
    @inbounds col = s.data[arch]
    if length(col) == 0
        error("entity has no $(string(C)) component")
    end
    return @inbounds col[row]
end

function _set_component!(s::_ComponentStorage{C}, arch::UInt32, row::UInt32, value::C) where C
    @inbounds col = s.data[arch]
    if length(col) == 0
        error("entity has no $(string(C)) component")
    end
    return @inbounds col[row] = value
end

function _add_column!(storage::_ComponentStorage{C}) where {C}
    push!(storage.data, Vector{C}())
end

function _assign_column!(storage::_ComponentStorage{C}, index::UInt32, capacity::UInt32) where {C}
    vec = Vector{C}()
    sizehint!(vec, capacity)
    storage.data[index] = vec
end

function _ensure_column_size!(storage::_ComponentStorage{C}, arch::UInt32, needed::UInt32) where {C}
    col = storage.data[arch]
    if length(col) < needed
        resize!(col, needed)
    end
end

function _move_component_data!(s::_ComponentStorage{C}, old_arch::UInt32, new_arch::UInt32, row::UInt32) where C
    old_vec = s.data[old_arch]
    new_vec = s.data[new_arch]
    push!(new_vec, old_vec[row])
    _swap_remove!(old_vec, row)
end

function _remove_component_data!(s::_ComponentStorage{C}, arch::UInt32, row::UInt32) where C
    col = s.data[arch]
    _swap_remove!(col, row)
end
