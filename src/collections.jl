
struct _IdCollection
    tables::Vector{UInt32}
    indices::Dict{UInt32,Int}
end

# TODO: rename to reflect it is just a collection of IDs
function _IdCollection()
    return _IdCollection(Vector{UInt32}(), Dict{UInt32,Int}())
end

function _IdCollection(tables::UInt32...)
    vec = collect(UInt32, tables)
    indices = Dict{UInt32,Int}()

    for (i, table) in enumerate(tables)
        indices[table] = i
    end

    return _IdCollection(vec, indices)
end

# TODO: rename to reflect it is just a collection of IDs
function _add_table!(ids::_IdCollection, table::UInt32)
    push!(ids.tables, table)
    ids.indices[table] = length(ids.tables)
    return nothing
end

# TODO: rename to reflect it is just a collection of IDs
function _remove_table!(ids::_IdCollection, table::UInt32)
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

function _contains(ids::_IdCollection, table::UInt32)
    return haskey(ids.indices, table)
end

function _clear!(ids::_IdCollection)
    resize!(ids.tables, 0)
    empty!(ids.indices)
    return nothing
end

Base.length(t::_IdCollection) = length(t.tables)
Base.@propagate_inbounds Base.getindex(t::_IdCollection, i::Int) = t.tables[i]

const _empty_tables::Vector{UInt32} = Vector{UInt32}()
const _empty_table_ids::_IdCollection = _IdCollection()
