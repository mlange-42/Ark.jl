
struct _TableIDs
    tables::Vector{_Table}
    indices::Dict{UInt32,Int}
end

function _TableIDs(tables::_Table...)
    vec = collect(tables)
    indices = Dict{UInt32,Int}()

    for (i, table) in enumerate(tables)
        indices[table.id] = i
    end

    return _TableIDs(vec, indices)
end

function _add_table!(ids::_TableIDs, table::_Table)
    push!(ids.tables, table)
    ids.indices[table.id] = length(ids.tables)
    return nothing
end

function _remove_table!(ids::_TableIDs, table::_Table)
    if !haskey(ids.indices, table.id)
        return false
    end
    idx = ids.indices[table.id]
    last = length(ids.tables)
    if idx != last
        ids.tables[idx], ids.tables[last] = ids.tables[last], ids.tables[idx]
        ids.indices[ids.tables[idx].id] = idx
    end
    pop!(ids.tables)
    delete!(ids.indices, table.id)
    return true
end

Base.length(t::_TableIDs) = length(t.tables)
Base.@propagate_inbounds Base.getindex(t::_TableIDs, i::Int) = t.tables[i]

const _empty_tables = Vector{_Table}()

struct _Archetype{M}
    components::Vector{Int}  # Indices into the global ComponentStorage list
    relations::Vector{Int}
    tables::_TableIDs
    index::Vector{Dict{UInt32,_TableIDs}}
    mask::_Mask{M}
    node::_GraphNode{M}
    id::UInt32
end

function _Archetype(id::UInt32, node::_GraphNode, tables::_TableIDs)
    _Archetype(Vector{Int}(), Vector{Int}(), tables, Vector{Dict{UInt32,_TableIDs}}(), node.mask, node, id)
end

function _Archetype(
    id::UInt32,
    node::_GraphNode,
    tables::_TableIDs,
    relations::Vector{Int},
    components::Int...,
)
    _Archetype(
        collect(Int, components),
        relations,
        tables,
        [Dict{UInt32,_TableIDs}() for _ in eachindex(relations)],
        node.mask,
        node, id,
    )
end

function _add_table!(indices::Vector{_ComponentRelations}, arch::_Archetype, t::_Table)
    _add_table!(arch.tables, t)

    if !_has_relations(arch)
        return
    end

    for (comp, target) in t.relations
        idx = indices[comp].archetypes[arch.id]
        dict = arch.index[idx]
        if haskey(dict, target._id)
            _add_table!(dict[target._id], t)
            continue
        end
        dict[target._id] = _TableIDs(t)
    end
end

_has_relations(a::_Archetype) = !isempty(a.relations)

struct _BatchTable{M}
    table::_Table
    archetype::_Archetype{M}
    start_idx::UInt32
    end_idx::UInt32
end
