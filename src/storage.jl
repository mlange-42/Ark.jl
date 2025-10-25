
struct _ComponentStorage{C}
    data::Vector{Union{Nothing,Column{C}}}  # Outer Vec: one per archetype
end

function _ComponentStorage{C}(archetypes::Int) where C
    _ComponentStorage{C}(Vector{Union{Nothing,Column{C}}}(nothing, archetypes))
end

function _assign_column!(storage::_ComponentStorage{C}, index::UInt32) where {C}
    storage.data[index] = _new_column(C)
end

function _move_component_data!(s::_ComponentStorage{C}, old_arch::UInt32, new_arch::UInt32, row::UInt32) where C
    old_vec = s.data[Int(old_arch)]
    new_vec = s.data[Int(new_arch)]
    push!(new_vec._data, old_vec[row])
    _swap_remove!(old_vec._data, row)
end

function _remove_component_data!(s::_ComponentStorage{C}, arch::UInt32, row::UInt32) where C
    col = s.data[Int(arch)]
    _swap_remove!(col._data, row)
end
