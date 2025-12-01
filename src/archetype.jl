
struct _TableIDs
    tables::Vector{Ref{_Table}}
    indices::Dict{UInt32,Int}
end

function _TableIDs(tables::Ref{_Table}...)
    vec = collect(tables)
    indices = Dict{UInt32,Int}()

    for (i, table) in enumerate(tables)
        indices[table[].id] = i
    end

    return _TableIDs(vec, indices)
end

function _add_table!(ids::_TableIDs, table::Ref{_Table})
    push!(ids.tables, table)
    ids.indices[table[].id] = length(ids.tables)
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
        ids.indices[ids.tables[idx][].id] = idx
    end
    pop!(ids.tables)
    delete!(ids.indices, table.id)
    return true
end

function _clear!(ids::_TableIDs)
    resize!(ids.tables, 0)
    empty!(ids.indices)
    return nothing
end

Base.length(t::_TableIDs) = length(t.tables)
Base.@propagate_inbounds Base.getindex(t::_TableIDs, i::Int) = t.tables[i]

const _empty_tables = Vector{Ref{_Table}}()

struct _Archetype{M}
    components::Vector{Int}  # Indices into the global ComponentStorage list
    relations::Vector{Int}
    tables::_TableIDs
    index::Vector{Dict{UInt32,_TableIDs}}
    target_tables::Dict{UInt32,_TableIDs}
    free_tables::Vector{Ref{_Table}}
    mask::_Mask{M}
    node::_GraphNode{M}
    id::UInt32
end

function _Archetype(id::UInt32, node::_GraphNode, table::_Table)
    _Archetype(
        Vector{Int}(),
        Vector{Int}(),
        _TableIDs(Ref{_Table}(table)),
        Vector{Dict{UInt32,_TableIDs}}(),
        Dict{UInt32,_TableIDs}(),
        Vector{Ref{_Table}}(),
        node.mask,
        node,
        id,
    )
end

function _Archetype(
    id::UInt32,
    node::_GraphNode,
    relations::Vector{Int},
    components::Int...,
)
    _Archetype(
        collect(Int, components),
        relations,
        _TableIDs(),
        [Dict{UInt32,_TableIDs}() for _ in eachindex(relations)],
        Dict{UInt32,_TableIDs}(),
        Vector{Ref{_Table}}(),
        node.mask,
        node, id,
    )
end

function _add_table!(indices::Vector{_ComponentRelations}, arch::_Archetype, t::Ref{_Table})
    _add_table!(arch.tables, t)

    if !_has_relations(arch)
        return
    end

    for (comp, target) in t[].relations
        idx = indices[comp].archetypes[arch.id]
        dict = arch.index[idx]
        if haskey(dict, target._id)
            _add_table!(dict[target._id], t)
        else
            dict[target._id] = _TableIDs(t)
        end

        if haskey(arch.target_tables, target._id)
            tables = arch.target_tables[target._id]
            if !haskey(tables.indices, t[].id)
                _add_table!(tables, t)
            end
        else
            arch.target_tables[target._id] = _TableIDs(t)
        end
    end
end

_has_relations(a::_Archetype) = !isempty(a.relations)

function _free_table!(a::_Archetype, table::_Table)
    _remove_table!(a.tables, table)
    push!(a.free_tables, Ref{_Table}(table))

    # If there is only one relation, the resp. relation_tables
    # entry is removed anyway.
    if length(a.relations) <= 1
        return
    end

    # TODO: can/should we be more selective here?
    for dict in a.index
        for (_, tables) in dict
            _remove_table!(tables, table)
        end
    end
    for (_, tables) in a.target_tables
        _remove_table!(tables, table)
    end
end

function _get_free_table!(a::_Archetype)::Tuple{Ref{_Table},Bool}
    if isempty(a.free_tables)
        return Ref{_Table}(), false
    end
    return pop!(a.free_tables), true
end

function _remove_target!(a::_Archetype, target::Entity)
    for dict in a.index
        delete!(dict, target._id)
    end
    delete!(a.target_tables, target._id)
    return nothing
end

function _reset!(a::_Archetype)
    if !_has_relations(a)
        return
    end

    for table in a.tables.tables
        push!(a.free_tables, table)
    end
    _clear!(a.tables)

    for dict in a.index
        empty!(dict)
    end
    empty!(a.target_tables)

    return
end

struct _BatchTable{M}
    table::_Table
    archetype::_Archetype{M}
    start_idx::UInt32
    end_idx::UInt32
end
