struct _ComponentIndex{M}
    components::Vector{Vector{_Archetype{M}}}
end

function _ComponentIndex{M}(components::Int) where M
    return _ComponentIndex([Vector{_Archetype{M}}() for _ in 1:components])
end
