
struct ComponentStorage{C}
    data::Vector{Union{Nothing, Vector{C}}}  # Outer Vec: one per archetype
end

function ComponentStorage{C}() where C
    ComponentStorage{C}(Vector{Union{Nothing, Vector{C}}}())
end

struct Archetype
    component_indices::Vector{Int}  # Indices into the global ComponentStorage list
end
