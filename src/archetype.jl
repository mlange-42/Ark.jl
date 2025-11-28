
struct _TableIDs
    ids::Vector{Int}
    indices::Dict{Int,Int}
end

function _TableIDs(ids::Int...)
    vec = Int[ids...]
    indices = Dict{Int,Int}()

    for (i, id) in enumerate(ids)
        indices[id] = i
    end

    return _TableIDs(vec, indices)
end

function _add_table!(ids::_TableIDs, id::Int)
    push!(ids.ids, id)
    ids.indices[id] = length(ids.ids)
    return nothing
end

function _remove_table!(ids::_TableIDs, id::Int)
    if !haskey(ids.indices, id)
        return false
    end
    idx = ids.indices[id]
    last = length(ids.ids)
    if idx != last
        ids.ids[idx], ids.ids[last] = ids.ids[last], ids.ids[idx]
        ids.indices[ids.ids[idx]] = idx
    end
    pop!(ids.ids)
    delete!(ids.indices, id)
    return true
end

struct _Archetype{M}
    entities::Entities
    components::Vector{Int}  # Indices into the global ComponentStorage list
    mask::_Mask{M}
    node::_GraphNode{M}
    id::UInt32
end

function _Archetype(id::UInt32, node::_GraphNode)
    _Archetype(Entities(0), Vector{Int}(), node.mask, node, id)
end

function _Archetype(id::UInt32, node::_GraphNode, cap::Int, components::Int...)
    _Archetype(Entities(cap), collect(Int, components), node.mask, node, id)
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
