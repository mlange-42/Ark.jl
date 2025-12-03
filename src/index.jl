struct _ComponentIndex{M}
    archetypes::Vector{Vector{_Archetype{M}}}
    archetypes_hot::Vector{Vector{_ArchetypeHot{M}}}
end

function _ComponentIndex{M}(components::Int) where M
    return _ComponentIndex(
        [Vector{_Archetype{M}}() for _ in 1:components],
        [Vector{_ArchetypeHot{M}}() for _ in 1:components],
    )
end
