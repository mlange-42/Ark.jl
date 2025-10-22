
"""
    const zero_entity::Entity

The reserved zero [`Entity`](@ref) value.
"""
const zero_entity::Entity = _new_entity(1, 0)

"""
    World{CS<:Tuple,CT<:Tuple,N}

The World is the central ECS storage.
"""
mutable struct World{CS<:Tuple,CT<:Tuple,N}
    _entities::Vector{_EntityIndex}
    _storages::CS
    _archetypes::Vector{_Archetype}
    _registry::_ComponentRegistry
    _entity_pool::_EntityPool
    _lock::_Lock
    _graph::_Graph
end

"""
    World(types::Type...)

Creates a new, empty [`World`](@ref).
"""
World(comp_types::Type...) = _World_from_types(Val{Tuple{comp_types...}}())

@generated function _component_id(world::World{CS}, ::Type{C})::UInt8 where {CS<:Tuple,C}
    storage_types = CS.parameters
    for (i, S) in enumerate(storage_types)
        if S <: _ComponentStorage && S.parameters[1] === C
            return :(UInt8($i))
        end
    end
    return :(error("Component type $(string(C)) not found in the World"))
end

@generated function _get_storage(world::World{CS}, ::Type{C})::_ComponentStorage{C} where {CS<:Tuple,C}
    storage_types = CS.parameters
    for (i, S) in enumerate(storage_types)
        if S <: _ComponentStorage && S.parameters[1] === C
            return :(world._storages[$i])
        end
    end
    return :(error("Component type $(string(C)) not found in the World"))
end

@generated function _get_storage(world::World{CS}, ::Val{C})::_ComponentStorage{C} where {CS<:Tuple,C}
    storage_types = CS.parameters
    for (i, S) in enumerate(storage_types)
        if S <: _ComponentStorage && S.parameters[1] === C
            return :(world._storages[$i])
        end
    end
    return :(error("Component type $(string(C)) not found in the World"))
end

@generated function _get_storage_by_id(world::World{CS}, ::Val{id}) where {CS<:Tuple,id}
    S = CS.parameters[id]
    T = S.parameters[1]
    return :(world._storages[$id]::_ComponentStorage{$(QuoteNode(T))})
end

function _find_or_create_archetype!(world::World, entity::Entity, add::Tuple{Vararg{UInt8}}, remove::Tuple{Vararg{UInt8}})::UInt32
    index = world._entities[entity._id]
    return _find_or_create_archetype!(world, world._archetypes[index.archetype].node, add, remove)
end

function _find_or_create_archetype!(world::World, start::_GraphNode, add::Tuple{Vararg{UInt8}}, remove::Tuple{Vararg{UInt8}})::UInt32
    node = _find_node(world._graph, start, add, remove)

    archetype = (node.archetype == typemax(UInt32)) ?
                _create_archetype!(world, node) :
                node.archetype

    return archetype
end

function _create_archetype!(world::World, node::_GraphNode)::UInt32
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

function _create_entity!(world::World, archetype_index::UInt32)::Tuple{Entity,UInt32}
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

function _move_entity!(world::World, entity::Entity, archetype_index::UInt32)::UInt32
    _check_locked(world)

    index = world._entities[entity._id]
    old_archetype = world._archetypes[index.archetype]
    new_archetype = world._archetypes[archetype_index]

    new_row = _add_entity!(new_archetype, entity)
    swapped = _swap_remove!(old_archetype.entities._data, index.row)

    # Move component data only for components present in old_archetype that are also present in new_archetype
    for comp::UInt8 in old_archetype.components
        if !_get_bit(new_archetype.mask, comp)
            continue
        end
        # comp casting to match generated helper signature
        _move_component_data!(world, comp, index.archetype, archetype_index, index.row)
    end

    # Ensure columns in the new archetype have capacity to hold new_row for components of new_archetype
    for comp::UInt8 in new_archetype.components
        _ensure_column_size_for_comp!(world, comp, archetype_index, new_row)
    end

    if swapped
        swap_entity = old_archetype.entities[index.row]
        world._entities[swap_entity._id] = index
    end

    world._entities[entity._id] = _EntityIndex(archetype_index, new_row)
    return new_row
end

"""
    new_entity!(world::World)::Entity

Creates a new [`Entity`](@ref) without any components.
"""
function new_entity!(world::World)::Entity
    entity, _ = _create_entity!(world, UInt32(1))
    return entity
end

"""
    remove_entity!(world::World, entity::Entity)

Removes an [`Entity`](@ref) from the [`World`](@ref).
"""
function remove_entity!(world::World, entity::Entity)
    if !is_alive(world, entity)
        error("can't remove a dead entity")
    end
    _check_locked(world)

    index = world._entities[entity._id]
    archetype = world._archetypes[index.archetype]

    swapped = _swap_remove!(archetype.entities._data, index.row)

    # Only operate on storages for components present in this archetype
    for comp::UInt8 in archetype.components
        # ensure comp has the integer kind expected by the generated helper
        _swap_remove_in_column_for_comp!(world, comp, index.archetype, index.row)
    end

    if swapped
        swap_entity = archetype.entities[index.row]
        world._entities[swap_entity._id] = index
    end

    _recycle(world._entity_pool, entity)
end

"""
    is_alive(world::World, entity::Entity)::Bool

Returns whether an [`Entity`](@ref) is alive.
"""
function is_alive(world::World, entity::Entity)::Bool
    return _is_alive(world._entity_pool, entity)
end

function _check_locked(world::World)
    if _is_locked(world._lock)
        error("cannot modify a locked world: collect entities into a vector and apply changes after query iteration has completed")
    end
end

"""
    is_locked(world::World)::Bool

Returns whether the world is currently locked for modifications.
"""
function is_locked(world::World)::Bool
    return _is_locked(world._lock)
end

@generated function _World_from_types(::Val{CS}) where {CS<:Tuple}
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
        World{$(storage_tuple_type),$(component_tuple_type),$(length(types))}(
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

@generated function _push_nothing_to_all!(world::World{CS,CT,N}) where {CS<:Tuple,CT<:Tuple,N}
    n = length(CS.parameters)
    # TODO: check! but should not be possible
    #if n == 0
    #    return :(nothing)
    #end
    exprs = Expr[]
    for i in 1:n
        push!(exprs, :(push!((world._storages).$i.data, nothing)))
    end
    return Expr(:block, exprs...)
end

@generated function _assign_new_column_for_comp!(world::World{CS,CT,N}, comp::UInt8, index::UInt32) where {CS<:Tuple,CT<:Tuple,N}
    n = length(CS.parameters)
    # TODO: check! but should not be possible
    #if n == 0
    #    return :(nothing)
    #end

    expr = nothing
    for i in n:-1:1
        T = CT.parameters[i]
        elt = T.parameters[1]
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

@generated function _ensure_column_size_for_comp!(world::World{CS,CT,N}, comp::UInt8, slot::UInt32, needed::UInt32) where {CS<:Tuple,CT<:Tuple,N}
    n = length(CS.parameters)
    # TODO: check! but should not be possible
    #if n == 0
    #    return :(nothing)
    #end

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

@generated function _move_component_data!(world::World{CS,CT,N}, comp::UInt8, old_slot::UInt32, new_slot::UInt32, row::UInt32) where {CS<:Tuple,CT<:Tuple,N}
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

@generated function _swap_remove_in_column_for_comp!(world::World{CS,CT,N}, comp::UInt8, slot::UInt32, row::UInt32) where {CS<:Tuple,CT<:Tuple,N}
    n = length(CS.parameters)
    if n == 0
        return :(nothing)
    end

    expr = nothing
    for i in n:-1:1
        stmt = :(
            begin
                col = ((world._storages).$i).data[Int(slot)]
                _swap_remove!(col._data, row)
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

"""
    get_components(world::World, entity::Entity, comp_types::Type...)

Get the given components for an entity.
"""
function get_components(world::World{CS,CT,N}, entity::Entity, comp_types::Type...) where {CS<:Tuple,CT<:Tuple,N}
    if !is_alive(world, entity)
        error("can't get components of a dead entity")
    end
    return _get_components(world, entity, Val{Tuple{comp_types...}}())
end

@generated function _get_components(world::World{CS,CT,N}, entity::Entity, ::Val{TS}) where {CS<:Tuple,CT<:Tuple,N,TS<:Tuple}
    types = TS.parameters
    if length(types) == 0
        return :(())
    end

    exprs = Expr[]
    push!(exprs, :(idx = world._entities[entity._id]))

    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        val_sym = Symbol("v", i)

        push!(exprs, :(
            $(stor_sym) = _get_storage(world, Val{$(QuoteNode(T))}())
        ))
        push!(exprs, :(
            $(col_sym) = $(stor_sym).data[idx.archetype]
        ))
        push!(exprs, :(
            $(val_sym) = $(col_sym)._data[idx.row]
        ))
    end

    vals = [:($(Symbol("v", i))) for i in 1:length(types)]
    push!(exprs, Expr(:return, Expr(:tuple, vals...)))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

"""
    set_components(world::World, entity::Entity, values...)

Sets the given component values for an entity. Types are inferred from the values.
"""
function set_components!(world::World{CS,CT,WN}, entity::Entity, values::Tuple) where {CS<:Tuple,CT<:Tuple,WN}
    return _set_components!(world, entity, Val{typeof(values)}(), values)
end

@generated function _set_components!(world::World{CS,CT,WN}, entity::Entity, ::Val{TS}, values::TV) where {CS<:Tuple,CT<:Tuple,WN,TS<:Tuple,TV<:Tuple}
    types = TS.parameters
    exprs = [:(idx = world._entities[entity._id])]

    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        val_sym = :(values[$i])

        push!(exprs, :($stor_sym = _get_storage(world, Val{$(QuoteNode(T))}())))
        push!(exprs, :($col_sym = $stor_sym.data[idx.archetype]))
        push!(exprs, :($col_sym._data[idx.row] = $val_sym))
    end

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end
