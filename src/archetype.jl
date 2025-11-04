
struct _Archetype
    entities::Entities
    components::Vector{UInt8}  # Indices into the global ComponentStorage list
    mask::_Mask
    node::_GraphNode
    id::UInt32
end

function _Archetype(id::UInt32, node::_GraphNode)
    _Archetype(Entities(), Vector{UInt8}(), node.mask, node, id)
end

function _Archetype(id::UInt32, node::_GraphNode, components::UInt8...)
    _Archetype(Entities(), collect(components), node.mask, node, id)
end

function _add_entity!(arch::_Archetype, entity::Entity)::UInt32
    push!(arch.entities._data, entity)
    return length(arch.entities)
end

Base.resize!(arch::_Archetype, length::Int) = Base.resize!(arch.entities._data, length)

struct _BatchArchetype
    archetype::_Archetype
    start_idx::UInt32
    end_idx::UInt32
end
