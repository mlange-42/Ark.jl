
struct _Archetype
    entities::Entities
    components::Vector{UInt8}  # Indices into the global ComponentStorage list
    mask::_Mask
    node::_GraphNode
end

function _Archetype(node::_GraphNode)
    _Archetype(Entities(), Vector{UInt8}(), node.mask, node)
end

function _Archetype(node::_GraphNode, components::UInt8...)
    _Archetype(Entities(), collect(components), node.mask, node)
end

function _add_entity!(arch::_Archetype, entity::Entity)::UInt32
    push!(arch.entities._data, entity)
    return length(arch.entities)
end