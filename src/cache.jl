
struct _MaskFilter{M}
    _mask::_Mask{M}
    _exclude_mask::_Mask{M}
    _relations::Vector{Pair{Int,Entity}}
    _tables::_TableIDs
    _id::Base.RefValue{UInt32}
    _has_excluded::Bool
end

struct _Cache{M}
    filters::Vector{_MaskFilter{M}}
    table_filters::Dict{UInt32,Vector{UInt32}}
end

function _register_filter(world::W, cache::_Cache, filter::F) where {W<:_AbstractWorld,F<:_MaskFilter}
    push!(cache.filters, filter)
    filter._id[] = length(cache.filters)
end
