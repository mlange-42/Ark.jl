
mutable struct WorldGen{CS<:Tuple,N}
    _entities::Vector{_EntityIndex}
    _storages::CS
    _archetypes::Vector{_Archetype}
    _registry::_ComponentRegistry
    _entity_pool::_EntityPool
    _lock::_Lock
    _graph::_Graph
end

@generated function _worldgen_from_types(::Val{CS}) where {CS<:Tuple}
    types = CS.parameters  # e.g., (Position, Velocity)

    # Generate storage types: Tuple{_ComponentStorage{Position}, _ComponentStorage{Velocity}}
    storage_types = [:(_ComponentStorage{$(QuoteNode(T))}) for T in types]
    storage_tuple_type = :(Tuple{$(storage_types...)})

    # Generate storage values
    storage_exprs = [:(_ComponentStorage{$(QuoteNode(T))}()) for T in types]
    storage_tuple = Expr(:tuple, storage_exprs...)

    return quote
        graph = _Graph()
        WorldGen{$storage_tuple_type,$(length(types))}(
            [_EntityIndex(typemax(UInt32), 0)],
            $storage_tuple,
            [_Archetype(graph.nodes[1])],
            _ComponentRegistry(),
            _EntityPool(UInt32(1024)),
            _Lock(),
            graph,
        )
    end
end

WorldGen(types::Type...) = _worldgen_from_types(Val{Tuple{types...}}())

"""
function WorldGen(comp_types::Tuple{Vararg{DataType}})
    graph = _Graph()
    World(
        [_EntityIndex(typemax(UInt32), 0)],
        ???,
        [_Archetype(graph.nodes[1])],
        _ComponentRegistry(),
        _EntityPool(UInt32(1024)),
        _Lock(),
        graph,
    )
end
"""