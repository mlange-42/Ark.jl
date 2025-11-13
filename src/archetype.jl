
struct _Archetype{M}
    entities::Entities
    components::Vector{UInt8}  # Indices into the global ComponentStorage list
    mask::_Mask{M}
    node::_GraphNode{M}
    id::UInt32
end

function _Archetype(id::UInt32, node::_GraphNode)
    _Archetype(Entities(0), Vector{UInt8}(), node.mask, node, id)
end

function _Archetype(id::UInt32, node::_GraphNode, cap::Int, components::UInt8...)
    _Archetype(Entities(cap), collect(UInt8, components), node.mask, node, id)
end

function _add_entity!(arch::_Archetype, entity::Entity)::Int
    push!(arch.entities._data, entity)
    return length(arch.entities)
end

Base.resize!(arch::_Archetype, length::Int) = Base.resize!(arch.entities._data, length)

struct _BatchArchetype{M}
    archetype::_Archetype{M}
    start_idx::UInt32
    end_idx::UInt32
end
