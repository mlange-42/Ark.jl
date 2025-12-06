
struct _MaskFilter{M}
    _mask::_Mask{M}
    _exclude_mask::_Mask{M}
    _relations::Vector{Pair{Int,Entity}}
    _has_excluded::Bool
end

struct _Cache{M}
    filters::Vector{_MaskFilter{M}}
end
