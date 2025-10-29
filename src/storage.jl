
struct _ComponentStorage{C}
    data::Vector{Union{Nothing,Vector{C}}}  # Outer Vec: one per archetype
end

function _ComponentStorage{C}(archetypes::Int) where C
    _ComponentStorage{C}(Vector{Union{Nothing,Vector{C}}}(nothing, archetypes))
end

function _assign_column!(storage::_ComponentStorage{C}, index::UInt32) where {C}
    storage.data[index] = Vector{C}()
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
