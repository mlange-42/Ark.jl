
struct _ComponentStorage{C}
    data::Vector{Union{Nothing,Vector{C}}}  # Outer Vec: one per archetype
end

function _ComponentStorage{C}() where C
    _ComponentStorage{C}(Vector{Union{Nothing,Vector{C}}}())
end

function _ComponentStorage{C}(archetypes::Int) where C
    _ComponentStorage{C}(Vector{Union{Nothing,Vector{C}}}(nothing, archetypes))
end
