
"""
    const zero_entity::Entity

The reserved zero [`Entity`](@ref) value.
"""
const zero_entity::Entity = _new_entity(1, 0)

"""
    World{CS<:Tuple,CT<:Tuple,N}

The World is the central ECS storage.
"""
struct World{CS<:Tuple,CT<:Tuple,N}
    _entities::Vector{_EntityIndex}
    _storages::CS
    _archetypes::Vector{_Archetype}
    _index::_ComponentIndex
    _registry::_ComponentRegistry
    _entity_pool::_EntityPool
    _lock::_Lock
    _graph::_Graph
    _resources::Dict{DataType,Any}
end

"""
    World(comp_types::Type...; allow_mutable::Bool=false)

Creates a new, empty [`World`](@ref) for the given component types.

# Arguments

  - `comp_types`: The component types used by the world.
  - `allow_mutable`: Allows mutable components. Use with care, as all mutable objects are heap-allocated in Julia.

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
world = World(Position, Velocity)
;

# output

```
"""
World(comp_types::Type...; allow_mutable::Bool=false) =
    _World_from_types(Val{Tuple{comp_types...}}(), Val(allow_mutable))

@generated function _component_id(::Type{CS}, ::Type{C})::UInt8 where {CS<:Tuple,C}
    for (i, S) in enumerate(CS.parameters)
        if S <: _ComponentStorage && S.parameters[1] === C
            return :(UInt8($i))
        end
    end
    return :(error(lazy"Component type $C not found in World"))
end

@generated function _get_storage(world::World{CS}, ::Type{C})::_ComponentStorage{C} where {CS<:Tuple,C}
    storage_types = CS.parameters
    for (i, S) in enumerate(storage_types)
        if S <: _ComponentStorage && S.parameters[1] === C
            return :(world._storages.$i)
        end
    end
    return :(error(lazy"Component type $C not found in the World"))
end

@generated function _get_storage_by_id(world::World{CS}, ::Val{id}) where {CS<:Tuple,id}
    S = CS.parameters[id]
    T = S.parameters[1]
    return :(world._storages.$id::_ComponentStorage{$T})
end

function _find_or_create_archetype!(
    world::World,
    entity::Entity,
    add::Tuple{Vararg{UInt8}},
    remove::Tuple{Vararg{UInt8}},
)::UInt32
    index = world._entities[entity._id]
    return _find_or_create_archetype!(world, world._archetypes[index.archetype].node, add, remove)
end

function _find_or_create_archetype!(
    world::World,
    start::_GraphNode,
    add::Tuple{Vararg{UInt8}},
    remove::Tuple{Vararg{UInt8}},
)::UInt32
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

    _push_nothing_to_all!(world)

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

function _create_entities!(world::World, archetype_index::UInt32, n::UInt32)::Tuple{UInt32,UInt32}
    _check_locked(world)

    archetype = world._archetypes[Int(archetype_index)]
    old_length = length(archetype.entities)
    new_length = old_length + n

    resize!(archetype, new_length)
    for i in (old_length+1):new_length
        entity = _get_entity(world._entity_pool)
        @inbounds archetype.entities._data[i] = entity

        if entity._id > length(world._entities)
            push!(world._entities, _EntityIndex(archetype_index, i))
        else
            @inbounds world._entities[Int(entity._id)] = _EntityIndex(archetype_index, i)
        end
    end

    for comp::UInt8 in archetype.components
        _ensure_column_size_for_comp!(world, comp, archetype_index, UInt32(new_length))
    end

    return old_length + 1, new_length
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
        _swap_remove_in_column_for_comp!(world, comp, index.archetype, index.row)
    end

    if swapped
        swap_entity = archetype.entities[index.row]
        world._entities[swap_entity._id] = index
    end

    _recycle(world._entity_pool, entity)
    return nothing
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
        error(
            "cannot modify a locked world: collect entities into a vector and apply changes after query iteration has completed",
        )
    end
end

"""
    @get_components(world::World, entity::Entity, comp_types::Tuple)

Get the given components for an [`Entity`](@ref).
Components are returned in a tuple.

Macro version of [`get_components`](@ref) for more ergonomic component type tuples.

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
            Val.($(esc(comp_types_expr))),
        )
    end
end

"""
    get_components(world::World, entity::Entity, comp_types::Tuple)

Get the given components for an [`Entity`](@ref).
Components are returned in a tuple.

For a more convenient tuple syntax, the macro [`@get_components`](@ref) is provided.

# Example

```julia
pos, vel = get_components(world, entity, Val.((Position, Velocity)))
```
"""
@inline function get_components(world::World, entity::Entity, comp_types::Tuple)
    if !is_alive(world, entity)
        error("can't get components of a dead entity")
    end
    return @inline _get_components(world, entity, comp_types)
end

@generated function _get_components(world::World, entity::Entity, ::TS) where {TS<:Tuple}
    types = _try_to_types(TS)
    if length(types) == 0
        return :(())
    end

    exprs = Expr[]
    push!(exprs, :(@inbounds idx = world._entities[entity._id]))

    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        val_sym = Symbol("v", i)

        push!(exprs, :($(stor_sym) = _get_storage(world, $T)))
        push!(exprs, :($(val_sym) = _get_component($(stor_sym), idx.archetype, idx.row)))
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
    @has_components(world::World, entity::Entity, comp_types::Tuple)::Bool

Returns whether an [`Entity`](@ref) has all given components.

Macro version of [`has_components`](@ref has_components(::World, ::Entity, ::Tuple))
for more ergonomic component type tuples.

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
            Val.($(esc(comp_types_expr))),
        )
    end
end

"""
    has_components(world::World, entity::Entity, comp_types::Tuple)::Bool

Returns whether an [`Entity`](@ref) has all given components.

For a more convenient tuple syntax, the macro [`@has_components`](@ref) is provided.

# Example

```julia
has = has_components(world, entity, Val.((Position, Velocity)))
```
"""
@inline function has_components(world::World, entity::Entity, comp_types::Tuple)
    if !is_alive(world, entity)
        error("can't check components of a dead entity")
    end
    index = world._entities[entity._id]
    return @inline _has_components(world, index, comp_types)
end

@generated function _has_components(world::World, index::_EntityIndex, ::TS) where {TS<:Tuple}
    types = _try_to_types(TS)
    exprs = []

    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)

        push!(exprs, :($stor_sym = _get_storage(world, $T)))
        push!(exprs, :($col_sym = $stor_sym.data[index.archetype]))
        push!(exprs, :(
            if length($col_sym) == 0
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
@inline function set_components!(world::World, entity::Entity, values::Tuple)
    if !is_alive(world, entity)
        error("can't set components of a dead entity")
    end
    return @inline _set_components!(world, entity, Val{typeof(values)}(), values)
end

@generated function _set_components!(world::World, entity::Entity, ::Val{TS}, values::Tuple) where {TS<:Tuple}
    types = TS.parameters
    exprs = [:(@inbounds idx = world._entities[entity._id])]

    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        val_expr = :(values.$i)

        push!(exprs, :($stor_sym = _get_storage(world, $T)))
        push!(exprs, :(_set_component!($stor_sym, idx.archetype, idx.row, $val_expr)))
    end

    push!(exprs, Expr(:return, :nothing))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

"""
    new_entity!(world::World, values::Tuple)::Entity

Creates a new [`Entity`](@ref) with the given component values. Types are inferred from the values.
"""
function new_entity!(world::World, values::Tuple)
    return _new_entity!(world, Val{typeof(values)}(), values)
end

@generated function _new_entity!(world::W, ::Val{TS}, values::Tuple) where {W<:World,TS<:Tuple}
    types = TS.parameters
    exprs = []

    ids = tuple([_component_id(W.parameters[1], T) for T in types]...)

    push!(exprs, :(archetype = _find_or_create_archetype!(world, world._archetypes[1].node, $ids, ())))
    push!(exprs, :(tmp = _create_entity!(world, archetype)))
    push!(exprs, :(entity = tmp[1]))
    push!(exprs, :(index = tmp[2]))

    # Set each component
    for i in 1:length(types)
        T = types[i]
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        val_expr = :(values.$i)

        push!(exprs, :($stor_sym = _get_storage(world, $T)))
        push!(exprs, :(@inbounds $col_sym = $stor_sym.data[archetype]))
        push!(exprs, :(@inbounds $col_sym[index] = $val_expr))
    end

    push!(exprs, Expr(:return, :entity))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

"""
    new_entities!(world::World, n::Int, defaults::Tuple; iterate::Bool=false)::Union{Batch,Nothing}

Creates the given number of [`Entity`](@ref), initialized with default values.
Component types are inferred from the provided default values.

If `iterate` is true, a [`Batch`](@ref) iterator over the newly created entities is returned
that can be used for initialization.

# Arguments

  - `world::World`: The `World` instance to use.
  - `n::Int`: The number of entities to create.
  - `defaults::Tuple`: A tuple of default values for initialization, like `(Position(0, 0), Velocity(1, 1))`.
  - `iterate::Bool`: Whether to return a batch for individual entity initialization.
"""
function new_entities!(world::World, n::Int, defaults::Tuple; iterate::Bool=false)
    return _new_entities_from_defaults!(world, UInt32(n), Val{typeof(defaults)}(), defaults, iterate)
end

@generated function _new_entities_from_defaults!(
    world::W,
    n::UInt32,
    ::Val{TS},
    values::Tuple,
    iterate::Bool,
) where {W<:World,TS<:Tuple}
    types = TS.parameters
    exprs = []

    ids = tuple([_component_id(W.parameters[1], T) for T in types]...)

    push!(exprs, :(archetype_idx = _find_or_create_archetype!(world, world._archetypes[1].node, $ids, ())))
    push!(exprs, :(indices = _create_entities!(world, archetype_idx, n)))
    push!(exprs, :(archetype = world._archetypes[archetype_idx]))

    if length(types) > 0
        body_exprs = Expr(:block)
        for i in 1:length(types)
            T = types[i]
            stor_sym = Symbol("stor", i)
            col_sym = Symbol("col", i)
            val_expr = :(values.$i)

            push!(body_exprs.args, :($stor_sym = _get_storage(world, $T)))
            push!(body_exprs.args, :(@inbounds $col_sym = $stor_sym.data[archetype_idx]))
            push!(body_exprs.args, :(fill!(view($col_sym, Int(indices[1]):Int(indices[2])), $val_expr)))
        end
        push!(exprs, :(
            if !isempty(values)
                $(body_exprs)
            end
        ))
    end

    types_tuple_type_expr = Expr(:curly, :Tuple, [:($T) for T in types]...)
    ts_val_expr = :(Val{$(types_tuple_type_expr)}())
    push!(exprs, :(
        if iterate
            batch = _Batch_from_types(
                world,
                [_BatchArchetype(archetype, indices...)],
                $ts_val_expr,
            )
            return batch
        else
            return nothing
        end
    ))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

"""
    @new_entities!(world::World, n::Int, comp_types::Tuple{Vararg{Val}})::Batch

Creates the given number of [`Entity`](@ref).

Returns a [`Batch`](@ref) iterator over the newly created entities that should be used to initialize components.
Note that components are not initialized/undef unless set in the iterator.

Macro version of [`new_entities!`](@ref new_entities!(::World, n:Int, ::Tuple{Vararg{Val}}))
for ergonomic construction of component mappers.

# Arguments

  - `world::World`: The `World` instance to use.
  - `n::Int`: The number of entities to create.
  - `comp_types::Tuple`: Component types for the new entities, like `(Position, Velocity)`.
"""
macro new_entities!(world_expr, n_expr, comp_types_expr)
    quote
        new_entities!(
            $(esc(world_expr)),
            $(esc(n_expr)),
            Val.($(esc(comp_types_expr))),
        )
    end
end

"""
    new_entities!(world::World, n::Int, comp_types::Tuple{Vararg{Val}})::Batch

Creates the given number of [`Entity`](@ref).

Returns a [`Batch`](@ref) iterator over the newly created entities that should be used to initialize components.
Note that components are not initialized/undef unless set in the iterator!

For a more convenient tuple syntax, the macro [`@new_entities!`](@ref) is provided.

# Arguments

  - `world::World`: The `World` instance to use.
  - `n::Int`: The number of entities to create.
  - `comp_types::Tuple`: Component types for the new entities, like `Val.((Position, Velocity))`.
"""
function new_entities!(world::World, n::Int, comp_types::Tuple{Vararg{Val}})
    return _new_entities_from_types!(world, UInt32(n), comp_types)
end

@generated function _new_entities_from_types!(world::W, n::UInt32, ::TS) where {W<:World,TS<:Tuple}
    types = _try_to_types(TS)
    exprs = []

    ids = tuple([_component_id(W.parameters[1], T) for T in types]...)

    push!(exprs, :(archetype_idx = _find_or_create_archetype!(world, world._archetypes[1].node, $ids, ())))
    push!(exprs, :(indices = _create_entities!(world, archetype_idx, n)))
    push!(exprs, :(archetype = world._archetypes[archetype_idx]))

    types_tuple_type_expr = Expr(:curly, :Tuple, [:($T) for T in types]...)
    # TODO: do we really need this?
    ts_val_expr = Expr(:call, Expr(:curly, :Val, types_tuple_type_expr))
    push!(exprs,
        :(batch = _Batch_from_types(
            world,
            [_BatchArchetype(archetype, indices[1], indices[2])],
            $ts_val_expr)
        ),
    )

    push!(exprs, Expr(:return, :batch))

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
function add_components!(world::World, entity::Entity, values::Tuple)
    if !is_alive(world, entity)
        error("can't add components to a dead entity")
    end
    return _exchange_components!(world, entity, Val{typeof(values)}(), values, ())
end

"""
    @remove_components!(world::World, entity::Entity, comp_types::Tuple)

Removes the given components from an [`Entity`](@ref).

Macro version of [`remove_components!`](@ref remove_components!(::World, ::Entity, ::Tuple))
for ergonomic construction of component mappers.

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
            Val.($(esc(comp_types_expr))),
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
function remove_components!(world::World, entity::Entity, comp_types::Tuple)
    if !is_alive(world, entity)
        error("can't remove components from a dead entity")
    end
    return _exchange_components!(world, entity, Val{Tuple{}}(), (), comp_types)
end

"""
    @exchange_components!(world::World, entity::Entity; add::Tuple, remove::Tuple)

Removes the given components from an [`Entity`](@ref).

Macro version of [`exchange_components!`](@ref) for more ergonomic component type tuples.

# Example

```julia
@exchange_components!(world, entity,
    add = (Health(100),),
    remove = Val.((Position, Velocity)),
)
```
"""
macro exchange_components!(world_expr, entity_expr)
    :(Query($(esc(world_expr)), $(esc(entity_expr))))
end
macro exchange_components!(kwargs_expr, world_expr, entity_expr)
    map(x -> (x.args[1] == :remove && (x.args[2] = :(Val.($(x.args[2]))))), kwargs_expr.args)
    quote
        exchange_components!(
            $(esc(world_expr)),
            $(esc(entity_expr));
            $(esc.(kwargs_expr.args)...),
        )
    end
end

"""
    exchange_components!(world::World{CS,CT,N}, entity::Entity; add::Tuple, remove::Tuple)

Adds and removes components on an [`Entity`](@ref). Types are inferred from the add values.

For a more convenient tuple syntax, the macro [`@exchange_components!`](@ref) is provided.

# Example

```julia
exchange_components!(world, entity;
    add=(Health(100),),
    remove=Val.((Position, Velocity)),
)
```
"""
function exchange_components!(world::World, entity::Entity; add::Tuple=(), remove::Tuple=())
    if !is_alive(world, entity)
        error("can't exchange components on a dead entity")
    end
    return _exchange_components!(world, entity, Val{typeof(add)}(), add, remove)
end

@generated function _exchange_components!(
    world::W,
    entity::Entity,
    ::Val{ATS},
    add::Tuple,
    ::RTS,
) where {W<:World,ATS<:Tuple,RTS<:Tuple}
    add_types = ATS.parameters
    rem_types = _try_to_types(RTS)
    exprs = []

    add_ids = tuple([_component_id(W.parameters[1], T) for T in add_types]...)
    rem_ids = tuple([_component_id(W.parameters[1], T) for T in rem_types]...)
    push!(exprs, :(archetype = _find_or_create_archetype!(world, entity, $add_ids, $rem_ids)))
    push!(exprs, :(row = _move_entity!(world, entity, archetype)))

    for i in 1:length(add_types)
        T = add_types[i]
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        val_expr = :(add.$i)

        push!(exprs, :($stor_sym = _get_storage(world, $T)))
        push!(exprs, :(@inbounds $col_sym = $stor_sym.data[archetype]))
        push!(exprs, :(@inbounds $col_sym[row] = $val_expr))
    end

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
                error(lazy"Component type $T must be immutable.")
            end
        end
    end

    component_types = map(T -> :(Type{$T}), types)
    component_tuple_type = :(Tuple{$(component_types...)})

    storage_types = [:(_ComponentStorage{$T}) for T in types]
    storage_tuple_type = :(Tuple{$(storage_types...)})

    storage_exprs = [:(_ComponentStorage{$T}(1)) for T in types]
    storage_tuple = Expr(:tuple, storage_exprs...)

    id_exprs = [:(_register_component!(registry, $T)) for T in types]
    id_tuple = Expr(:tuple, id_exprs...)

    return quote
        registry = _ComponentRegistry()
        ids = $id_tuple
        graph = _Graph()
        World{$(storage_tuple_type),$(component_tuple_type),$(length(types))}(
            [_EntityIndex(typemax(UInt32), 0)],
            $storage_tuple,
            [_Archetype(UInt32(1), graph.nodes[1])],
            _ComponentIndex($(length(types))),
            registry,
            _EntityPool(UInt32(1024)),
            _Lock(),
            graph,
            Dict{DataType,Any}(),
        )
    end
end

@generated function _push_nothing_to_all!(world::World{CS}) where {CS<:Tuple}
    n = length(CS.parameters)
    exprs = Expr[]
    for i in 1:n
        push!(exprs, :(_add_column!(world._storages.$i)))
    end
    return Expr(:block, exprs...)
end

@generated function _assign_new_column_for_comp!(world::World{CS}, comp::UInt8, index::UInt32) where {CS}
    n = length(CS.parameters)
    exprs = Expr[]
    for i in 1:n
        push!(exprs, :(
            if comp == $i
                _assign_column!(world._storages.$i, index)
            end
        ))
    end
    return Expr(:block, exprs...)
end

@generated function _ensure_column_size_for_comp!(
    world::World{CS},
    comp::UInt8,
    arch::UInt32,
    needed::UInt32,
) where {CS<:Tuple}
    n = length(CS.parameters)
    exprs = Expr[]
    for i in 1:n
        push!(exprs, :(
            if comp == $i
                _ensure_column_size!(world._storages.$i, arch, needed)
            end
        ))
    end
    return Expr(:block, exprs...)
end

@generated function _move_component_data!(
    world::World{CS},
    comp::UInt8,
    old_arch::UInt32,
    new_arch::UInt32,
    row::UInt32,
) where {CS<:Tuple}
    n = length(CS.parameters)
    exprs = Expr[]
    for i in 1:n
        push!(exprs, :(
            if comp == $i
                _move_component_data!(world._storages.$i, old_arch, new_arch, row)
            end
        ))
    end
    return Expr(:block, exprs...)
end

@generated function _swap_remove_in_column_for_comp!(
    world::World{CS},
    comp::UInt8,
    arch::UInt32,
    row::UInt32,
) where {CS<:Tuple}
    n = length(CS.parameters)
    exprs = Expr[]
    for i in 1:n
        push!(exprs, :(
            if comp == $i
                _remove_component_data!(world._storages.$i, arch, row)
            end
        ))
    end
    return Expr(:block, exprs...)
end

"""
    get_resource(world::World, res_type::Type{T})::T

Get the resource of type `T` from the world.
"""
function get_resource(world::World, res_type::Type{T})::T where T
    getindex(world._resources, res_type)::T
end

"""
    has_resource(world::World, res_type::Type{T})::Bool

Check if a resource of type `T` is in the world.
"""
function has_resource(world::World, res_type::Type)::Bool
    res_type in keys(world._resources)
end

"""
    add_resource!(world::World, res::T)::T

Add the given resource to the world.
Returns the newly added resource.
"""
function add_resource!(world::World, res::T)::T where T
    has_resource(world, T) && error(lazy"World already contains a resource of type $T.")
    setindex!(world._resources, res, T)
    return res
end

"""
    set_resource!(world::World, res::T)::T

Overwrites an existing resource in the world.
Returns the newly overwritten resource.
"""
function set_resource!(world::World, res::T)::T where T
    !has_resource(world, T) && error(lazy"World does not contain a resource of type $T.")
    setindex!(world._resources, res, T)
    return res
end

"""
    remove_resource!(world::World, res_type::Type{T})::T

Remove the resource of type `T` from the world.
Returns the removed resource.
"""
function remove_resource!(world::World, res_type::Type{T}) where T
    res = pop!(world._resources, res_type)
    return res::T
end
