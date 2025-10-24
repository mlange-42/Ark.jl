struct _ComponentIndex
    components::Vector{Vector{_Archetype}}
end

function _ComponentIndex(components::Int)
    return _ComponentIndex([Vector{_Archetype}() for _ in 1:components])
end
