
struct _ComponentStorage{C}
    data::Vector{Union{Nothing,Column{C}}}  # Outer Vec: one per archetype
end

function _ComponentStorage{C}(archetypes::Int) where C
    _ComponentStorage{C}(Vector{Union{Nothing,Column{C}}}(nothing, archetypes))
end
