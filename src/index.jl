struct _ComponentIndex{K}
    components::Vector{Vector{_Archetype{K}}}
end

function _ComponentIndex{K}(components::Int) where K
    return _ComponentIndex([Vector{_Archetype{K}}() for _ in 1:components])
end
