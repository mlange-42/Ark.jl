
struct _TableIDs
    tables::Vector{UInt32}
    indices::Dict{UInt32,Int}
end

function _TableIDs(tables::UInt32...)
    vec = collect(tables)
    indices = Dict{UInt32,Int}()

    for (i, table) in enumerate(tables)
        indices[table] = i
    end

    return _TableIDs(vec, indices)
end

function _add_table!(ids::_TableIDs, table::UInt32)
    push!(ids.tables, table)
    ids.indices[table] = length(ids.tables)
    return nothing
end

function _remove_table!(ids::_TableIDs, table::UInt32)
    if !haskey(ids.indices, table)
        return false
    end
    idx = ids.indices[table]
    last = length(ids.tables)
    if idx != last
        ids.tables[idx], ids.tables[last] = ids.tables[last], ids.tables[idx]
        ids.indices[ids.tables[idx]] = idx
    end
    pop!(ids.tables)
    delete!(ids.indices, table)
    return true
end

function _clear!(ids::_TableIDs)
    resize!(ids.tables, 0)
    empty!(ids.indices)
    return nothing
end

Base.length(t::_TableIDs) = length(t.tables)
Base.@propagate_inbounds Base.getindex(t::_TableIDs, i::Int) = t.tables[i]

const _empty_tables = Vector{UInt32}()

struct _ArchetypeData
    target_tables::Dict{UInt32,_TableIDs}
    free_tables::Vector{UInt32}
end

function _ArchetypeData()
    return _ArchetypeData(
        Dict{UInt32,_TableIDs}(),
        Vector{UInt32}(),
    )
end

mutable struct _Archetype{M}
    const components::Vector{Int}
    const tables::_TableIDs
    const index::Vector{Dict{UInt32,_TableIDs}}
    const node::Base.RefValue{_GraphNode{M}}
    const num_relations::UInt32
    const table::UInt32
    const id::UInt32
end

function _Archetype(id::UInt32, node::Base.RefValue{_GraphNode{M}}, table::UInt32) where {M}
    _Archetype(
        Vector{Int}(),
        _TableIDs(table),
        Vector{Dict{UInt32,_TableIDs}}(),
        node,
        UInt32(0),
        table,
        id,
    )
end

function _Archetype(
    id::UInt32,
    node::Base.RefValue{_GraphNode{M}},
    table::UInt32,
    relations::Vector{Int},
    components::Int...,
) where {M}
    _Archetype(
        collect(Int, components),
        _TableIDs(),
        [Dict{UInt32,_TableIDs}() for _ in eachindex(relations)],
        node,
        UInt32(length(relations)),
        table,
        id,
    )
end

function _add_table!(indices::Vector{_ComponentRelations}, arch::_Archetype, data::_ArchetypeData, t::_Table)
    _add_table!(arch.tables, t.id)

    if !_has_relations(arch)
        return
    end

    for (comp, target) in t.relations
        idx = indices[comp].archetypes[arch.id]
        dict = arch.index[idx]
        if haskey(dict, target._id)
            _add_table!(dict[target._id], t.id)
        else
            dict[target._id] = _TableIDs(t.id)
        end

        if haskey(data.target_tables, target._id)
            tables = data.target_tables[target._id]
            if !haskey(tables.indices, t.id)
                _add_table!(tables, t.id)
            end
        else
            data.target_tables[target._id] = _TableIDs(t.id)
        end
    end
end

_has_relations(a::_Archetype) = a.num_relations > 0

function _free_table!(a::_Archetype, data::_ArchetypeData, table::_Table)
    _remove_table!(a.tables, table.id)
    push!(data.free_tables, table.id)

    # If there is only one relation, the resp. relation_tables
    # entry is removed anyway.
    if a.num_relations <= 1
        return
    end

    # TODO: can/should we be more selective here?
    for dict in a.index
        for (_, tables) in dict
            _remove_table!(tables, table.id)
        end
    end
    for (_, tables) in data.target_tables
        _remove_table!(tables, table.id)
    end
end

function _get_free_table!(a::_ArchetypeData)::Tuple{UInt32,Bool}
    if isempty(a.free_tables)
        return 0, false
    end
    return pop!(a.free_tables), true
end

function _remove_target!(a::_Archetype, data::_ArchetypeData, target::Entity)
    for dict in a.index
        delete!(dict, target._id)
    end
    delete!(data.target_tables, target._id)
end

function _reset!(a::_Archetype, data::_ArchetypeData)
    if !_has_relations(a)
        return
    end

    for table in a.tables.tables
        push!(data.free_tables, table)
    end
    _clear!(a.tables)

    for dict in a.index
        empty!(dict)
    end
    empty!(data.target_tables)

    return
end

struct _BatchTable{M}
    table::_Table
    archetype::_Archetype{M}
    start_idx::UInt32
    end_idx::UInt32
end
