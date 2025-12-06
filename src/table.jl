
struct _TableIDs
    tables::Vector{UInt32}
    indices::Dict{UInt32,Int}
end

# TODO: rename to reflect it is just a collection of IDs
function _TableIDs()
    return _TableIDs(Vector{UInt32}(), Dict{UInt32,Int}())
end

function _TableIDs(tables::UInt32...)
    vec = collect(UInt32, tables)
    indices = Dict{UInt32,Int}()

    for (i, table) in enumerate(tables)
        indices[table] = i
    end

    return _TableIDs(vec, indices)
end

# TODO: rename to reflect it is just a collection of IDs
function _add_table!(ids::_TableIDs, table::UInt32)
    push!(ids.tables, table)
    ids.indices[table] = length(ids.tables)
    return nothing
end

# TODO: rename to reflect it is just a collection of IDs
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

function _contains(ids::_TableIDs, table::UInt32)
    return haskey(ids.indices, table)
end

function _clear!(ids::_TableIDs)
    resize!(ids.tables, 0)
    empty!(ids.indices)
    return nothing
end

Base.length(t::_TableIDs) = length(t.tables)
Base.@propagate_inbounds Base.getindex(t::_TableIDs, i::Int) = t.tables[i]

const _empty_tables = Vector{UInt32}()
const _empty_table_ids = _TableIDs()

struct _Table
    entities::Entities
    relations::Vector{Pair{Int,Entity}}
    filters::_TableIDs
    id::UInt32
    archetype::UInt32
end

function _new_table(id::UInt32, archetype::UInt32)
    return _Table(Entities(0), Pair{Int,Entity}[], _TableIDs(), id, archetype)
end

function _new_table(id::UInt32, archetype::UInt32, cap::Int, relations::Vector{Pair{Int,Entity}})
    return _Table(Entities(cap), relations, _TableIDs(), id, archetype)
end

_has_relations(t::_Table) = !isempty(t.relations)

function _matches(indices::Vector{_ComponentRelations}, t::_Table, relations::Vector{Pair{Int,Entity}})
    if length(relations) == 0 || !_has_relations(t)
        return true
    end
    for (comp, target) in relations
        @inbounds trg = indices[comp].targets[t.id]
        if target._id != trg._id
            return false
        end
    end
    return true
end

function _matches_exact(indices::Vector{_ComponentRelations}, t::_Table, relations::Vector{Pair{Int,Entity}})
    # This check is done in _get_table_slow_path
    #if length(relations) < length(t.relations)
    #    throw(ArgumentError("relation targets must be fully specified"))
    #end
    for (comp, target) in relations
        # TODO: check for components not in the table
        # TODO: check for components that are no relations
        @inbounds trg = indices[comp].targets[t.id]
        if target._id != trg._id
            return false
        end
    end
    return true
end

function _add_entity!(t::_Table, entity::Entity)::Int
    push!(t.entities._data, entity)
    return length(t.entities)
end

Base.resize!(t::_Table, length::Int) = Base.resize!(t.entities._data, length)
