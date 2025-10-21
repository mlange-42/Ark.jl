
mutable struct WorldGen{CS<:Tuple,CT<:Tuple,N}
    _entities::Vector{_EntityIndex}
    _storages::CS
    _archetypes::Vector{_Archetype}
    _registry::_ComponentRegistry
    _entity_pool::_EntityPool
    _lock::_Lock
    _graph::_Graph
end

@generated function _worldgen_from_types(::Val{CS}) where {CS<:Tuple}
    types = CS.parameters

    component_types = map(T -> :(Type{$(QuoteNode(T))}), types)
    component_tuple_type = :(Tuple{$(component_types...)})

    storage_types = [:(_ComponentStorage{$(QuoteNode(T))}) for T in types]
    storage_tuple_type = :(Tuple{$(storage_types...)})

    # storage tuple value
    storage_exprs = [:(_ComponentStorage{$(QuoteNode(T))}(1)) for T in types]
    storage_tuple = Expr(:tuple, storage_exprs...)

    # id registration tuple value
    id_exprs = [:(_register_component!(registry, $(QuoteNode(T)))) for T in types]
    id_tuple = Expr(:tuple, id_exprs...)

    return quote
        registry = _ComponentRegistry()
        ids = $id_tuple
        graph = _Graph()
        WorldGen{$(storage_tuple_type),$(component_tuple_type),$(length(types))}(
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

@generated function _component_id(world::WorldGen{CS}, ::Type{C})::UInt8 where {CS<:Tuple,C}
    storage_types = CS.parameters
    for (i, S) in enumerate(storage_types)
        if S <: _ComponentStorage && S.parameters[1] === C
            return :(UInt8($i))
        end
    end
    return :(error("Component type $(string(C)) not found in the World"))
end

@generated function _get_storage(world::WorldGen{CS}, ::Type{C})::_ComponentStorage{C} where {CS<:Tuple,C}
    storage_types = CS.parameters
    for (i, S) in enumerate(storage_types)
        if S <: _ComponentStorage && S.parameters[1] === C
            return :(world._storages[$i])
        end
    end
    return :(error("Component type $(string(C)) not found in the World"))
end

@generated function _get_storage(world::WorldGen{CS}, ::Val{C})::_ComponentStorage{C} where {CS<:Tuple,C}
    storage_types = CS.parameters
    for (i, S) in enumerate(storage_types)
        if S <: _ComponentStorage && S.parameters[1] === C
            return :(world._storages[$i])
        end
    end
    return :(error("Component type $(string(C)) not found in the World"))
end

@generated function _get_storage_by_id(world::WorldGen{CS}, ::Val{id}) where {CS<:Tuple,id}
    S = CS.parameters[id]
    T = S.parameters[1]
    return :(world._storages[$id]::_ComponentStorage{$(QuoteNode(T))})
end

function _find_or_create_archetype!(world::WorldGen, entity::Entity, add::Tuple{Vararg{UInt8}}, remove::Tuple{Vararg{UInt8}})::UInt32
    index = world._entities[entity._id]
    return _find_or_create_archetype!(world, world._archetypes[index.archetype].node, add, remove)
end

function _find_or_create_archetype!(world::WorldGen, start::_GraphNode, add::Tuple{Vararg{UInt8}}, remove::Tuple{Vararg{UInt8}})::UInt32
    node = _find_node(world._graph, start, add, remove)

    archetype = (node.archetype == typemax(UInt32)) ?
                _create_archetype!(world, node) :
                node.archetype

    return archetype
end

function _create_archetype!(world::WorldGen, node::_GraphNode)::UInt32
    components = _active_bit_indices(node.mask)
    arch = _Archetype(node, components...)
    push!(world._archetypes, arch)
    node.archetype = length(world._archetypes)

    index::UInt32 = length(world._archetypes)

    # type-stable: expand pushes to concrete storage fields
    _push_nothing_to_all!(world)

    # type-stable: assign new column to each component's storage with concrete accesses
    for comp::UInt8 in components
        _assign_new_column_for_comp!(world, comp, index)
    end

    return index
end

@generated function _push_nothing_to_all!(world::WorldGen{CS,CT,N}) where {CS<:Tuple,CT<:Tuple,N}
    n = length(CS.parameters)
    if n == 0
        return :(nothing)
    end
    exprs = Expr[]
    for i in 1:n
        push!(exprs, :(push!((world._storages).$i.data, nothing)))
    end
    return Expr(:block, exprs...)
end

@generated function _assign_new_column_for_comp!(world::WorldGen{CS,CT,N}, comp::UInt8, index::UInt32) where {CS<:Tuple,CT<:Tuple,N}
    n = length(CS.parameters)
    if n == 0
        return :(nothing)
    end

    expr = nothing
    for i in n:-1:1
        T = CT.parameters[i] # e.g. Type{Position} or Position
        # unwrap Type{X} -> X so _new_column receives X (not Type{X})
        if T <: Type
            elt = T.parameters[1]
        else
            elt = T
        end
        assign = :((world._storages).$i.data[index] = _new_column($(QuoteNode(elt))))
        if expr === nothing
            expr = :(
                if comp == $i
                    $assign
                end
            )
        else
            expr = :(
                if comp == $i
                    $assign
                else
                    $expr
                end
            )
        end
    end
    return expr
end