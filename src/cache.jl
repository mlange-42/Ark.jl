
struct _MaskFilter{M}
    mask::_Mask{M}
    exclude_mask::_Mask{M}
    relations::Vector{Pair{Int,Entity}}
    tables::_TableIDs
    id::Base.RefValue{UInt32}
    has_excluded::Bool
end

struct _Cache{M}
    filters::Vector{_MaskFilter{M}}
    table_filters::Dict{UInt32,Vector{UInt32}}
end

function _register_filter(
    arches::Vector{_Archetype},
    arches_hot::Vector{_ArchetypeHot},
    cache::_Cache,
    filter::F,
) where {F<:_MaskFilter}
    if filter.id[] != 0
        throw(InvalidStateException("filter is already registered to the cache", :filter_registered))
    end
    push!(cache.filters, filter)
    filter.id[] = length(cache.filters)

    for i in eachindex(arches)
        arch_hot = @inbounds arches_hot[i]
        if !_matches(filter, arch_hot)
            continue
        end

        if !arch_hot.has_relations
            _add_table!(filter._tables, arch_hot.table)
        end

        error("not implemented")
    end
end

function _unregister_filter(cache::_Cache, filter::F) where {W<:_AbstractWorld,F<:_MaskFilter}
    if filter.id[] == 0
        throw(InvalidStateException("filter is not registered to the cache", :filter_not_registered))
    end
    _clear!(filter.tables)
    filter.id[] = 0
end
