
"""
    const zero_entity::Entity

The reserved zero [`Entity`](@ref) value.
"""
const zero_entity::Entity = _new_entity(1, 0)

"""
    World{CS<:Tuple,CT<:Tuple,N}

The World is the central ECS storage.
"""
struct World{CS<:Tuple,CT<:Tuple,N,SizeFns,MoveFns,RemoveFns}
    _entities::Vector{_EntityIndex}
    _storages::CS
    _archetypes::Vector{_Archetype}
    _index::_ComponentIndex
    _registry::_ComponentRegistry
    _entity_pool::_EntityPool
    _lock::_Lock
    _graph::_Graph
    _resources::Dict{DataType,Any}

    _size_fns::SizeFns
    _move_fns::MoveFns
    _remove_fns::RemoveFns
end

"""
    World(comp_types::Type...; allow_mutable::Bool=false)

Creates a new, empty [`World`](@ref) for the given component types.

# Arguments
- `comp_types`: The component types used by the world.
- `allow_mutable`: Allows mutable components. Use with care, as they are heap-allocated.
"""
World(comp_types::Type...; allow_mutable::Bool=false) = _World_from_types(Val{Tuple{comp_types...}}(), Val(allow_mutable))

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
    arch = _Archetype(UInt32(length(world._archetypes) + 1), node, components...)
    push!(world._archetypes, arch)

    index::UInt32 = length(world._archetypes)
    node.archetype = index

    # type-stable: expand pushes to concrete storage fields
    _push_nothing_to_all!(world)

    # type-stable: assign new column to each component's storage with concrete accesses
    for comp::UInt8 in components
        _assign_new_column_for_comp!(world, comp, index)
        push!(world._index.components[comp], arch)
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
        @inbounds world._entities[entity._id] = _EntityIndex(archetype_index, index)
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

"""
    is_locked(world::World)::Bool

Returns whether the world is currently locked for modifications.
"""
function is_locked(world::World)::Bool
    return _is_locked(world._lock)
end

function _check_locked(world::World)
    if _is_locked(world._lock)
        error("cannot modify a locked world: collect entities into a vector and apply changes after query iteration has completed")
    end
end

"""
    @get_components(world::World, entity::Entity, comp_types::Tuple)

Get the given components for an [`Entity`](@ref).

Macro version of [`get_components`](@ref) for ergonomic construction of component mappers.

# Example
```julia
pos, vel = @get_components(world, entity, (Position, Velocity))
```
"""
macro get_components(world_expr, entity_expr, comp_types_expr)
    quote
        get_components(
            $(esc(world_expr)),
            $(esc(entity_expr)),
            Val.($(esc(comp_types_expr)))
        )
    end
end

"""
    get_components(world::World, entity::Entity, comp_types::Tuple)

Get the given components for an [`Entity`](@ref).

For a more convenient tuple syntax, the macro [`@get_components`](@ref) is provided.

# Example
```julia
pos, vel = get_components(world, entity, Val.((Position, Velocity)))
```
"""
function get_components(world::World{CS,CT,N}, entity::Entity, comp_types::Tuple) where {CS<:Tuple,CT<:Tuple,N}
    if !is_alive(world, entity)
        error("can't get components of a dead entity")
    end
    return _get_components(world, entity, comp_types)
end

@generated function _get_components(world::World{CS,CT,N}, entity::Entity, ::TS) where {CS<:Tuple,CT<:Tuple,N,TS<:Tuple}
    types = [x.parameters[1] for x in TS.parameters]
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
            $(stor_sym) = _get_storage(world, $(QuoteNode(T)))
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
    @has_components(world::World, entity::Entity, comp_types::Tuple)

Returns whether an [`Entity`](@ref) has all given components.

Macro version of [`has_components`](@ref) for ergonomic construction of component mappers.

# Example
```julia
has = @has_components(world, entity, (Position, Velocity))
```
"""
macro has_components(world_expr, entity_expr, comp_types_expr)
    quote
        has_components(
            $(esc(world_expr)),
            $(esc(entity_expr)),
            Val.($(esc(comp_types_expr)))
        )
    end
end

"""
    has_components(world::World, entity::Entity, comp_types::Tuple)

Returns whether an [`Entity`](@ref) has all given components.

For a more convenient tuple syntax, the macro [`@has_components`](@ref) is provided.

# Example
```julia
has = has_components(world, entity, Val.((Position, Velocity)))
```
"""
@inline function has_components(world::World{CS,CT,N}, entity::Entity, comp_types::Tuple) where {CS<:Tuple,CT<:Tuple,N}
    if !is_alive(world, entity)
        error("can't check components of a dead entity")
    end
    index = world._entities[entity._id]
    return _has_components(world, index, comp_types)
end

@generated function _has_components(world::World{CS,CT,N}, index::_EntityIndex, ::TS) where {CS<:Tuple,CT<:Tuple,N,TS<:Tuple}
    types = [x.parameters[1] for x in TS.parameters]
    exprs = []

    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)

        push!(exprs, :($stor_sym = _get_storage(world, $(QuoteNode(T)))))
        push!(exprs, :($col_sym = $stor_sym.data[index.archetype]))
        push!(exprs, :(
            if $col_sym === nothing
                return false
            end
        ))
    end

    push!(exprs, :(return true))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

"""
    set_components!(world::World, entity::Entity, values::Tuple)

Sets the given component values for an [`Entity`](@ref). Types are inferred from the values.
The entity must already have all these components.
"""
function set_components!(world::World{CS,CT,WN}, entity::Entity, values::Tuple) where {CS<:Tuple,CT<:Tuple,WN}
    if !is_alive(world, entity)
        error("can't set components of a dead entity")
    end
    return _set_components!(world, entity, Val{typeof(values)}(), values)
end

@generated function _set_components!(world::World{CS,CT,WN}, entity::Entity, ::Val{TS}, values::Tuple) where {CS<:Tuple,CT<:Tuple,WN,TS<:Tuple}
    types = TS.parameters
    exprs = [:(idx = world._entities[entity._id])]

    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        val_expr = :(values[$i])

        push!(exprs, :($stor_sym = _get_storage(world, $(QuoteNode(T)))))
        push!(exprs, :($col_sym = $stor_sym.data[idx.archetype]))
        push!(exprs, :($col_sym._data[idx.row] = $val_expr))
    end

    push!(exprs, Expr(:return, :nothing))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

"""
    new_entity!(world::World, comps::Vararg{Any})::Entity

Creates a new [`Entity`](@ref) without any components.
"""
function new_entity!(world::World)::Entity
    entity, _ = _create_entity!(world, UInt32(1))
    return entity
end

"""
    new_entity!(world::World, values::Tuple)::Entity

Creates a new [`Entity`](@ref) with the given component values. Types are inferred from the values.
"""
function new_entity!(world::World{CS,CT,N}, values::Tuple) where {CS<:Tuple,CT<:Tuple,N}
    return _new_entity!(world, Val{typeof(values)}(), values)
end

@generated function _new_entity!(world::World{CS,CT,N}, ::Val{TS}, values::Tuple) where {CS<:Tuple,CT<:Tuple,N,TS<:Tuple}
    types = TS.parameters
    exprs = []

    # Generate component IDs as a tuple
    id_exprs = [:(_component_id(world, $(QuoteNode(T)))) for T in types]
    push!(exprs, :(ids = ($(id_exprs...),)))  # Tuple, not Vector

    # Create archetype and entity
    push!(exprs, :(archetype = _find_or_create_archetype!(world, world._archetypes[1].node, ids, ())))
    push!(exprs, :(tmp = _create_entity!(world, archetype)))
    push!(exprs, :(entity = tmp[1]))
    push!(exprs, :(index = tmp[2]))

    # Set each component
    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        val_expr = :(values[$i])

        push!(exprs, :($stor_sym = _get_storage(world, $(QuoteNode(T)))))
        push!(exprs, :($col_sym = $stor_sym.data[archetype]))
        push!(exprs, :($col_sym._data[index] = $val_expr))
    end

    push!(exprs, Expr(:return, :entity))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

"""
    add_components!(world::World, entity::Entity, values::Tuple)

Adds the given component values to an [`Entity`](@ref). Types are inferred from the values.
"""
function add_components!(world::World{CS,CT,N}, entity::Entity, values::Tuple) where {CS<:Tuple,CT<:Tuple,N}
    if !is_alive(world, entity)
        error("can't add components to a dead entity")
    end
    return _add_components!(world, entity, Val{typeof(values)}(), values)
end

@generated function _add_components!(world::World{CS,CT,N}, entity::Entity, ::Val{TS}, values::Tuple) where {CS<:Tuple,CT<:Tuple,N,TS<:Tuple}
    types = TS.parameters
    exprs = []

    # Generate component IDs as a tuple
    id_exprs = [:(_component_id(world, $(QuoteNode(T)))) for T in types]
    push!(exprs, :(ids = ($(id_exprs...),)))

    # Find or create new archetype
    push!(exprs, :(archetype = _find_or_create_archetype!(world, entity, ids, ())))

    # Move entity to new archetype
    push!(exprs, :(row = _move_entity!(world, entity, archetype)))

    # Set each new component
    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        val_expr = :(values[$i])

        push!(exprs, :($stor_sym = _get_storage(world, $(QuoteNode(T)))))
        push!(exprs, :($col_sym = $stor_sym.data[archetype]))
        push!(exprs, :(@inbounds $col_sym._data[row] = $val_expr))
    end

    push!(exprs, Expr(:return, :nothing))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

"""
    @remove_components!(world::World, entity::Entity, comp_types::Tuple)

Removes the given components from an [`Entity`](@ref).

Macro version of [`remove_components!`](@ref) for ergonomic construction of component mappers.

# Example
```julia
@remove_components!(world, entity, (Position, Velocity))
```
"""
macro remove_components!(world_expr, entity_expr, comp_types_expr)
    quote
        remove_components!(
            $(esc(world_expr)),
            $(esc(entity_expr)),
            Val.($(esc(comp_types_expr)))
        )
    end
end

"""
    remove_components!(world::World, entity::Entity, comp_types::Tuple)

Removes the given components from an [`Entity`](@ref).

For a more convenient tuple syntax, the macro [`@remove_components!`](@ref) is provided.

# Example
```julia
remove_components!(world, entity, Val.((Position, Velocity)))
```
"""
function remove_components!(world::World{CS,CT,N}, entity::Entity, comp_types::Tuple) where {CS<:Tuple,CT<:Tuple,N}
    if !is_alive(world, entity)
        error("can't remove components from a dead entity")
    end
    return _remove_components!(world, entity, comp_types)
end

@generated function _remove_components!(world::World{CS,CT,N}, entity::Entity, ::TS) where {CS<:Tuple,CT<:Tuple,N,TS<:Tuple}
    types = [x.parameters[1] for x in TS.parameters]
    exprs = []

    # Generate component IDs to remove
    id_exprs = [:(_component_id(world, $(QuoteNode(T)))) for T in types]
    push!(exprs, :(remove_ids = ($(id_exprs...),)))

    # Find or create new archetype without those components
    push!(exprs, :(archetype = _find_or_create_archetype!(world, entity, (), remove_ids)))

    # Move entity to new archetype
    push!(exprs, :(_move_entity!(world, entity, archetype)))

    push!(exprs, Expr(:return, :nothing))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

@generated function _World_from_types(::Val{CS}, ::Val{MUT}) where {CS<:Tuple,MUT}
    types = CS.parameters

    allow_mutable = MUT::Bool
    if !allow_mutable
        for T in types
            if ismutabletype(T)
                error("Component type $T must be immutable.")
            end
        end
    end

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

    size_fns = make_size_callers(CS)
    move_fns = make_move_callers(CS)
    remove_fns = make_remove_callers(CS)

    return quote
        registry = _ComponentRegistry()
        ids = $id_tuple
        graph = _Graph()
        World{$(storage_tuple_type),$(component_tuple_type),$(length(types)),$(QuoteNode(typeof(size_fns))),$(QuoteNode(typeof(move_fns))),$(QuoteNode(typeof(remove_fns)))}(
            [_EntityIndex(typemax(UInt32), 0)],
            $storage_tuple,
            [_Archetype(UInt32(1), graph.nodes[1])],
            _ComponentIndex($(length(types))),
            registry,
            _EntityPool(UInt32(1024)),
            _Lock(),
            graph,
            Dict{DataType,Any}(),
            $size_fns,
            $move_fns,
            $remove_fns,
        )
    end
end

@generated function _push_nothing_to_all!(world::World{CS,CT,N}) where {CS<:Tuple,CT<:Tuple,N}
    n = length(CS.parameters)
    exprs = Expr[]
    for i in 1:n
        push!(exprs, :(push!((world._storages).$i.data, nothing)))
    end
    return Expr(:block, exprs...)
end

@generated function _assign_new_column_for_comp!(world::World{CS,CT,N}, comp::UInt8, index::UInt32) where {CS,CT,N}
    n = length(CS.parameters)
    exprs = Expr[]
    for i in 1:n
        push!(exprs, :(
            if comp == $i
                _assign_column!(world._storages[$i], index)
            end
        ))
    end
    return Expr(:block, exprs...)
end

function _ensure_column_size_for_comp!(world::World{CS}, comp::UInt8, arch::UInt32, needed::UInt32) where {CS<:Tuple}
    T = CS.parameters[Int(comp)]
    storage::_ComponentStorage = world._storages[Int(comp)]::T
    _ensure_column_size!(storage, arch, needed)
end

function _move_component_data!(world::World{CS}, comp::UInt8, old_arch::UInt32, new_arch::UInt32, row::UInt32) where {CS<:Tuple}
    fn = world._move_fns[Int(comp)]
    fn(world, old_arch, new_arch, row)
end

function _swap_remove_in_column_for_comp!(world::World{CS}, comp::UInt8, arch::UInt32, row::UInt32) where {CS<:Tuple}
    T = CS.parameters[Int(comp)]
    storage::_ComponentStorage = world._storages[Int(comp)]::T
    _remove_component_data!(storage, arch, row)
end

struct _SizeFn{C,I}
end

function (m::_SizeFn{C,I})(world::World, arch::UInt32, needed::UInt32) where {C,I}
    _ensure_column_size!(world._storages[I], arch, needed)
end

@generated function make_size_callers(::Type{CS}) where {CS<:Tuple}
    types = CS.parameters
    n = length(types)
    callers = Expr(:tuple, [:(_SizeFn{$(QuoteNode(types[i])),$(i)}()) for i in 1:n]...)
    return callers
end

struct _MoveFn{C,I}
end

function (m::_MoveFn{C,I})(world::World, old_arch::UInt32, new_arch::UInt32, row::UInt32) where {C,I}
    _move_component_data!(world._storages[I], old_arch, new_arch, row)
end

@generated function make_move_callers(::Type{CS}) where {CS<:Tuple}
    types = CS.parameters
    n = length(types)
    callers = Expr(:tuple, [:(_MoveFn{$(QuoteNode(types[i])),$(i)}()) for i in 1:n]...)
    return callers
end

struct _RemoveFn{C,I}
end

function (m::_RemoveFn{C,I})(world::World, arch::UInt32, index::UInt32) where {C,I}
    _remove_component_data!(world._storages[I], arch, index)
end

@generated function make_remove_callers(::Type{CS}) where {CS<:Tuple}
    types = CS.parameters
    n = length(types)
    callers = Expr(:tuple, [:(_RemoveFn{$(QuoteNode(types[i])),$(i)}()) for i in 1:n]...)
    return callers
end

"""
    get_resource(world::World, res_type::Type{T})

Get the resource of type `T` from the world.
"""
function get_resource(world::World, res_type::Type{T}) where T
    getindex(world._resources, res_type)::T
end

"""
    has_resource(world::World, res_type::Type{T})

Check if a resource of type `T` is in the world.
"""
function has_resource(world::World, res_type::Type)
    res_type in keys(world._resources)
end

"""
    add_resource!(world::World, res::T)

Add the given resource to the world.
"""
function add_resource!(world::World, res::T) where T
    has_resource(world, T) && error(lazy"World already contains a resource of type $T.")
    setindex!(world._resources, res, T)
    return res
end

"""
    remove_resource!(world::World, res_type::Type{T})

Remove the resource of type `T` from the world.
"""
function remove_resource!(world::World, res_type::Type)
    delete!(world._resources, res_type)
    return world
end
