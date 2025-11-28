
struct _TableIDs
    ids::Vector{UInt32}
    indices::Dict{UInt32,Int}
end

function _TableIDs(ids::Integer...)
    vec = UInt32[ids...]
    indices = Dict{UInt32,Int}()

    for (i, id) in enumerate(ids)
        indices[id] = i
    end

    return _TableIDs(vec, indices)
end

function _add_table!(ids::_TableIDs, id::UInt32)
    push!(ids.ids, id)
    ids.indices[id] = length(ids.ids)
    return nothing
end

function _remove_table!(ids::_TableIDs, id::UInt32)
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

Base.length(t::_TableIDs) = length(t.ids)
Base.getindex(t::_TableIDs, i::Int) = t.ids[i]

struct _Archetype{M}
    components::Vector{Int}  # Indices into the global ComponentStorage list
    relations::Vector{Int}
    tables::_TableIDs
    mask::_Mask{M}
    node::_GraphNode{M}
    id::UInt32
end

function _Archetype(id::UInt32, node::_GraphNode, tables::_TableIDs)
    _Archetype(Vector{Int}(), Vector{Int}(), tables, node.mask, node, id)
end

function _Archetype(
    id::UInt32,
    node::_GraphNode,
    tables::_TableIDs,
    relations::Vector{Int},
    components::Int...,
)
    _Archetype(collect(Int, components), relations, tables, node.mask, node, id)
end

function _add_table!(arch::_Archetype, t::_Table)
    _add_table!(arch.tables, t.id)
    if !_has_relations(arch)
        return
    end
    # TODO: add to relations index
    error("not implemented")
end

_has_relations(a::_Archetype) = length(a.relations) > 0

struct _BatchTable{M}
    table::_Table
    archetype::_Archetype{M}
    start_idx::UInt32
    end_idx::UInt32
end
