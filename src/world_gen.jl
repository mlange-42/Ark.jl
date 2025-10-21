
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

function _create_entity!(world::WorldGen, archetype_index::UInt32)::Tuple{Entity,UInt32}
    _check_locked(world)

    entity = _get_entity(world._entity_pool)
    archetype = world._archetypes[archetype_index]

    index = _add_entity!(archetype, entity)

    for comp::UInt8 in archetype.components
        _ensure_column_size_for_comp!(world, comp, archetype_index, index)
    end

    if entity._id > length(world._entities)
        push!(world._entities, _EntityIndex(archetype_index, index))
    else
        world._entities[entity._id] = _EntityIndex(archetype_index, index)
    end
    return entity, index
end

function _move_entity!(world::WorldGen, entity::Entity, archetype_index::UInt32)::UInt32
    _check_locked(world)

    index = world._entities[entity._id]
    old_archetype = world._archetypes[index.archetype]
    new_archetype = world._archetypes[archetype_index]

    new_row = _add_entity!(new_archetype, entity)
    swapped = _swap_remove!(old_archetype.entities._data, index.row)

    # Move component data only for components present in old_archetype that are also present in new_archetype
    for comp in old_archetype.components
        if !_get_bit(new_archetype.mask, comp)
            continue
        end
        # comp casting to match generated helper signature
        _move_component_data!(world, UInt8(comp), UInt32(index.archetype), archetype_index, index.row)
    end

    # Ensure columns in the new archetype have capacity to hold new_row for components of new_archetype
    for comp in new_archetype.components
        _ensure_column_size_for_comp!(world, UInt8(comp), archetype_index, new_row)
    end

    if swapped
        swap_entity = old_archetype.entities[index.row]
        world._entities[swap_entity._id] = index
    end

    world._entities[entity._id] = _EntityIndex(archetype_index, new_row)
    return new_row
end

function _check_locked(world::WorldGen)
    if _is_locked(world._lock)
        error("cannot modify a locked world: collect entities into a vector and apply changes after query iteration has completed")
    end
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

@generated function _ensure_column_size_for_comp!(world::WorldGen{CS,CT,N}, comp::UInt8, slot::UInt32, needed::UInt32) where {CS<:Tuple,CT<:Tuple,N}
    n = length(CS.parameters)
    if n == 0
        return :(nothing)
    end

    expr = nothing
    for i in n:-1:1
        stmt = :(
            begin
                col = ((world._storages).$i).data[Int(slot)]
                if length(col) < needed
                    resize!(col._data, needed)
                end
            end
        )
        if expr === nothing
            expr = :(
                if comp == $i
                    $stmt
                end
            )
        else
            expr = :(
                if comp == $i
                    $stmt
                else
                    $expr
                end
            )
        end
    end
    return expr
end

@generated function _move_component_data!(world::WorldGen{CS,CT,N}, comp::UInt8, old_slot::UInt32, new_slot::UInt32, row::UInt32) where {CS<:Tuple,CT<:Tuple,N}
    n = length(CS.parameters)
    if n == 0
        return :(nothing)
    end

    expr = nothing
    for i in n:-1:1
        # build statement using concrete storage field $i
        # Note: do not interpolate runtime names old_slot/new_slot/row; leave them as runtime vars
        stmt = quote
            begin
                old_vec = ((world._storages).$i).data[Int(old_slot)]
                new_vec = ((world._storages).$i).data[Int(new_slot)]
                push!(new_vec._data, old_vec[row])
                _swap_remove!(old_vec._data, row)
            end
        end
        if expr === nothing
            expr = :(
                if comp == $i
                    $stmt
                end
            )
        else
            expr = :(
                if comp == $i
                    $stmt
                else
                    $expr
                end
            )
        end
    end
    return expr
end
