
abstract type StorageTrait end
struct HasComponent <: StorageTrait end
struct MissingComponent <: StorageTrait end

storage_trait(::Vector{C}) where C = HasComponent()
storage_trait(::_Missing{C}) where C = MissingComponent()

_get_component(storage::Union{_Missing{C},Vector{C}}, i::Int) where C =
    _get_component(storage, i, storage_trait(storage))

function _get_component(storage::Vector{C}, i::Int, ::HasComponent) where C
    @inbounds return storage[i]
end

function _get_component(storage::_Missing{C}, i::Int, ::MissingComponent) where C
    error("entity has no $(string(C)) component")
end

_set_component!(storage::Union{_Missing{C},Vector{C}}, val, i::Int) where C =
    _set_component!(storage, val, i, storage_trait(storage))

function _set_component!(storage::Vector{C}, val, i::Int, ::HasComponent) where C
    @inbounds storage[i] = val
end

function _set_component!(storage::_Missing{C}, val, i::Int, ::MissingComponent) where C
    error("cannot set component $(string(C)) — it is missing")
end

struct _ComponentStorage{C}
    data::Vector{Union{_Missing{C},Vector{C}}}
end

function _ComponentStorage{C}(archetypes::Int) where C
    _ComponentStorage{C}(fill(_Missing{C}(), archetypes))
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
