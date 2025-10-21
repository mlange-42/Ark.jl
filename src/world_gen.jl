
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

    # Generate component ID registration calls
    id_exprs = [:(_register_component!(registry, $(QuoteNode(T)))) for T in types]
    id_tuple = Expr(:tuple, id_exprs...)

    return quote
        registry = _ComponentRegistry()
        ids = $id_tuple
        graph = _Graph()
        WorldGen{$storage_tuple_type,$(length(types))}(
            [_EntityIndex(typemax(UInt32), 0)],
            $storage_tuple,
            [_Archetype(graph.nodes[1])],
            registry,
            _EntityPool(UInt32(1024)),
            _Lock(),
            graph,
        )
    end
end

WorldGen(types::Type...) = _worldgen_from_types(Val{Tuple{types...}}())

#@inline function _component_id!(world::WorldGen, ::Type{C})::UInt8 where C
#return _get_id!(world._registry, C)
#end

@generated function _component_id(world::WorldGen{CS}, ::Type{C})::UInt8 where {CS<:Tuple,C}
    storage_types = CS.parameters
    for (i, S) in enumerate(storage_types)
        if S <: _ComponentStorage && S.parameters[1] === C
            return :(UInt8($i))
        end
    end
    return :(error("Component type $(string(C)) not found in the World"))
end