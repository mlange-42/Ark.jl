
struct _ComponentStorage{C}
    data::Vector{Union{Nothing, Vector{C}}}  # Outer Vec: one per archetype
end

function _ComponentStorage{C}() where C
    _ComponentStorage{C}(Vector{Union{Nothing, Vector{C}}}())
end

struct _Archetype
    component_indices::Vector{Int}  # Indices into the global ComponentStorage list
end
