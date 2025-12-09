
"""
    new_entities!(
        [f::Function],
        world::World,
        n::Int, 
        defaults::Tuple;
        relations:Tuple=(),
    )::Union{Batch,Nothing}

Creates the given number of [`Entity`](@ref), initialized with default values.
Component types are inferred from the provided default values.

The optional callback/`do` block can be used for initialization.
It takes a tuple of `(entities, columns...)` as argument.

See also [new_entities!](@ref new_entities!(::World, ::Int, ::Tuple)) for creating entities from component types.

# Arguments

  - `f::Function`: Optional callback for initialization, can be passed as a `do` block.
  - `world::World`: The `World` instance to use.
  - `n::Int`: The number of entities to create.
  - `defaults::Tuple`: A tuple of default values for initialization, like `(Position(0, 0), Velocity(1, 1))`.
  - `relations::Tuple`: Relationship component type => target entity pairs.
  - `iterate::Bool`: Whether to return a batch for individual entity initialization.

# Examples

Create 100 entities from default values:

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
new_entities!(world, 100, (Position(0, 0), Velocity(1, 1)))

# output

```

Create 100 entities from default values and iterate them:

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
new_entities!(world, 100, (Position(0, 0), Velocity(1, 1))) do (entities, positions, velocities)
    for i in eachindex(entities)
        positions[i] = Position(rand(), rand())
    end
end

# output

```
"""
Base.@constprop :aggressive function new_entities!(
    fn::F,
    world::World,
    n::Int,
    defaults::Tuple;
    relations::Tuple{Vararg{Pair{DataType,Entity}}}=(),
) where {F}
    if n == 0
        return
    end
    rel_types = ntuple(i -> Val(relations[i].first), length(relations))
    targets = ntuple(i -> relations[i].second, length(relations))
    return _new_entities_from_defaults!(fn, world, UInt32(n),
        Val{typeof(defaults)}(), defaults,
        rel_types, targets, Val(true))
end

Base.@constprop :aggressive function new_entities!(
    world::World,
    n::Int,
    defaults::Tuple;
    relations::Tuple{Vararg{Pair{DataType,Entity}}}=(),
)
    if n == 0
        return
    end
    rel_types = ntuple(i -> Val(relations[i].first), length(relations))
    targets = ntuple(i -> relations[i].second, length(relations))
    return _new_entities_from_defaults!(world, UInt32(n),
        Val{typeof(defaults)}(), defaults,
        rel_types, targets, Val(false)) do tuple
    end
end

Base.@constprop :aggressive function new_entities!(
    world::World,
    n::Int,
    defaults::Tuple{},
)
    if n == 0
        return
    end
    return _new_entities_from_defaults!(world, UInt32(n),
        Val{typeof(defaults)}(), defaults, (), (), Val(false)) do tuple
    end
end

"""
    new_entities!(
        f::Function,
        world::World,
        n::Int,
        comp_types::Tuple;
        relations:Tuple=(),
    )::Batch

Creates the given number of [`Entity`](@ref).

The callback/`do` block should be used to initialize components.
Note that components are not initialized/undef unless set in the callback.

See also [new_entities!](@ref new_entities!(::World, ::Int, ::Tuple; ::Bool)) for creating entities from default values.

# Arguments

  - `f::Function`: Callback for initialization, can be passed as a `do` block.
  - `world::World`: The `World` instance to use.
  - `n::Int`: The number of entities to create.
  - `comp_types::Tuple`: Component types for the new entities, like `(Position, Velocity)`.
  - `relations::Tuple`: Relationship component type => target entity pairs.

# Example

Create 100 entities from component types and initialize them:

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
new_entities!(world, 100, (Position, Velocity)) do (entities, positions, velocities)
    for i in eachindex(entities)
        positions[i] = Position(rand(), rand())
        velocities[i] = Velocity(1, 1)
    end
end

# output

```
"""
Base.@constprop :aggressive function new_entities!(
    fn::F,
    world::World,
    n::Int,
    comp_types::Tuple{Vararg{DataType}};
    relations::Tuple{Vararg{Pair{DataType,Entity}}}=(),
) where {F}
    if n == 0
        return
    end
    rel_types = ntuple(i -> Val(relations[i].first), length(relations))
    targets = ntuple(i -> relations[i].second, length(relations))
    return _new_entities_from_types!(fn, world, UInt32(n),
        ntuple(i -> Val(comp_types[i]), length(comp_types)),
        rel_types, targets)
end

function _get_tables(
    world::World,
    arches::Vector{_Archetype{M}},
    arches_hot::Vector{_ArchetypeHot{M}},
    filter::F,
)::Tuple{Vector{UInt32},Bool} where {M,F<:Filter}
    if _is_cached(filter._filter)
        tables = filter._filter.tables.ids
        any_relations = false
        for table_id in tables
            if _has_relations(world._tables[table_id])
                any_relations = true
            end
        end
        return tables, any_relations
    end

    tables = world._pool.tables
    any_relations = false
    for arch in eachindex(arches)
        @inbounds archetype_hot = arches_hot[arch]
        if !_matches(filter._filter, archetype_hot)
            continue
        end
        if !archetype_hot.has_relations
            table = @inbounds world._tables[Int(archetype_hot.table)]
            if isempty(table.entities)
                continue
            end
            push!(tables, table.id)
            continue
        end
        archetype = @inbounds arches[arch]
        if isempty(archetype.tables)
            continue
        end
        arch_tables = _get_tables(world, archetype, filter._filter.relations)
        for table_id in arch_tables
            table = @inbounds world._tables[Int(table_id)]
            if !isempty(table.entities) && _matches(world._relations, table, filter._filter.relations)
                push!(tables, table.id)
                any_relations = true
            end
        end
    end

    return tables, any_relations
end

"""
    remove_entities!([f::Function], world::World, filter::Filter)

Removes all entities that match the given [Filter](@ref) from the [World](@ref).

The optional callback/`do` block is called on them before the removal.
The callback's argument is an [Entities](@ref) list.

# Example

Removing entities:

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
filter = Filter(world, (Position, Velocity))
remove_entities!(world, filter)

# output

```

Removing entities using a callback:

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
filter = Filter(world, (Position, Velocity))
remove_entities!(world, filter) do entities
    # do something with the entities.
end

# output

```
"""
function remove_entities!(world::W, filter::F) where {W<:World,F<:Filter}
    _remove_entities!(world, filter, Val(false)) do entities
    end
end

function remove_entities!(fn::Fn, world::W, filter::F) where {Fn,W<:World,F<:Filter}
    _remove_entities!(fn, world, filter, Val(true))
end

@generated function _remove_entities!(fn::Fn, world::W, filter::F, ::HFN) where {Fn,W<:World,F<:Filter,HFN<:Val}
    CS = W.parameters[1]
    TS = F.parameters[2]
    OPT = F.parameters[4]

    comp_types = _to_types(TS.parameters)
    optional_flags = OPT.parameters

    required_ids = [_component_id(CS, comp_types[i]) for i in 1:length(comp_types) if optional_flags[i] === Val{false}]
    ids_tuple = tuple(required_ids...)

    # TODO: skit this for cached filters
    archetypes =
        length(ids_tuple) == 0 ? :((world._archetypes, world._archetypes_hot)) :
        :(_get_archetypes(world, $ids_tuple))

    world_has_rel = _has_relations(CS)
    has_fn = HFN == Val{true}
    quote
        _check_locked(world)

        arches, arches_hot = $archetypes
        tables, any_relations = _get_tables(world, arches, arches_hot, filter)

        has_entity_obs = _has_observers(world._event_manager, OnRemoveEntity)
        has_rel_obs = any_relations && _has_observers(world._event_manager, OnRemoveRelations)
        has_callback = $has_fn
        should_lock = has_entity_obs || has_rel_obs || has_callback

        l::Int64 = 0
        if should_lock
            l = _lock(world._lock)
        end

        $(has_fn ?
          :(
            for table_id in tables
                table = world._tables[table_id]
                if isempty(table)
                    continue
                end
                fn(table.entities)
            end
        ) :
          (:(nothing))
        )

        if has_entity_obs
            for table_id in tables
                table = world._tables[table_id]
                if isempty(table)
                    continue
                end
                _fire_remove_entities(
                    world._event_manager,
                    table,
                    world._archetypes_hot[table.archetype].mask,
                )
            end
        end
        if has_rel_obs
            for table_id in tables
                table = world._tables[table_id]
                if isempty(table)
                    continue
                end
                if _has_relations(table)
                    _fire_remove_entities_relations(
                        world._event_manager,
                        table,
                        world._archetypes_hot[table.archetype].mask,
                    )
                end
            end
        end

        if should_lock
            _unlock(world._lock, l)
        end

        cleanup = world._pool.entities
        for table_id in tables
            table = world._tables[table_id]
            if isempty(table)
                continue
            end
            for entity in table.entities
                $(world_has_rel ?
                  :(
                    if world._targets[entity._id]
                        push!(cleanup, entity)
                    end
                ) :
                  (:(nothing))
                )
                _recycle(world._entity_pool, entity)
            end
            resize!(table, 0)
            for comp in world._archetypes[table.archetype].components
                _clear_component_data!(world, comp, table.id)
            end
        end

        $(world_has_rel ?
          :(
            for entity in cleanup
                _cleanup_archetypes(world, entity)
                world._targets[entity._id] = false
            end
        ) :
          (:(nothing))
        )

        if !_is_cached(filter._filter) # Do not clear for cached filters!!!
            resize!(tables, 0)
        end
        resize!(cleanup, 0)

        return nothing
    end
end

@generated function _new_entities_from_defaults!(
    fn::F,
    world::W,
    n::UInt32,
    ::Val{TS},
    values::Tuple,
    ::TR,
    targets::Tuple{Vararg{Entity}},
    ::HFN,
) where {F,W<:World,TS<:Tuple,TR<:Tuple,HFN<:Val}
    types = _to_types(TS.parameters)
    rel_types = _to_types(TR)

    _check_no_duplicates(types)
    _check_no_duplicates(rel_types)
    _check_relations(rel_types)
    _check_is_subset(rel_types, types)

    CS = W.parameters[1]
    ids = tuple([_component_id(CS, T) for T in types]...)
    rel_ids = tuple([_component_id(CS, T) for T in rel_types]...)
    num_ids = length(ids)
    use_map = num_ids >= 4 ? _UseMap() : _NoUseMap()

    M = max(1, cld(length(CS.parameters), 64))
    add_mask = _Mask{M}(ids...)
    rem_mask = _Mask{M}()

    world_has_rel = Val{_has_relations(CS)}()

    exprs = []
    push!(
        exprs,
        :(
            table_idx = _find_or_create_table!(
                world,
                world._tables[1],
                $ids,
                (),
                $rel_ids,
                targets,
                $add_mask,
                $rem_mask,
                $use_map,
                $world_has_rel,
            )[1]
        ),
    )
    push!(exprs, :(indices = _create_entities!(world, table_idx, n)))
    push!(exprs, :(table = world._tables[table_idx]))

    if length(types) > 0
        body_exprs = Expr(:block)
        for i in 1:length(types)
            T = types[i]
            stor_sym = Symbol("stor", i)
            col_sym = Symbol("col", i)
            val_expr = :(values.$i)

            push!(body_exprs.args, :($stor_sym = _get_storage(world, $T)))
            push!(body_exprs.args, :(@inbounds $col_sym = $stor_sym.data[table_idx]))
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

    if HFN == Val{true}
        push!(
            exprs,
            :(
                begin
                    l = _lock(world._lock)
                    columns = _get_columns(world, $ts_val_expr, table, indices...)
                    fn(columns)

                    batch = _BatchTable(table, world._archetypes[table.archetype], indices...)
                    if _has_observers(world._event_manager, OnCreateEntity)
                        _fire_create_entities(world._event_manager, batch)
                    end
                    if _has_relations(table) && _has_observers(world._event_manager, OnAddRelations)
                        _fire_create_entities_relations(world._event_manager, batch)
                    end
                    _unlock(world._lock, l)
                    return nothing
                end
            ),
        )
    else
        push!(
            exprs,
            :(
                begin
                    has_entity_obs = _has_observers(world._event_manager, OnCreateEntity)
                    has_rel_obs = _has_relations(table) && _has_observers(world._event_manager, OnAddRelations)
                    if has_entity_obs || has_rel_obs
                        l = _lock(world._lock)
                        batch = _BatchTable(table, world._archetypes[table.archetype], indices...)
                        if has_entity_obs
                            _fire_create_entities(world._event_manager, batch)
                        end
                        if has_rel_obs
                            _fire_create_entities_relations(world._event_manager, batch)
                        end
                        _unlock(world._lock, l)
                    end
                    return nothing
                end
            ),
        )
    end

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

@generated function _new_entities_from_types!(
    fn::F,
    world::W,
    n::UInt32,
    ::TS,
    ::TR,
    targets::Tuple{Vararg{Entity}},
) where {W<:World,TS<:Tuple,TR<:Tuple,F}
    types = _to_types(TS)
    rel_types = _to_types(TR)

    _check_no_duplicates(types)
    _check_no_duplicates(rel_types)
    _check_relations(rel_types)
    _check_is_subset(rel_types, types)

    CS = W.parameters[1]
    ids = tuple([_component_id(CS, T) for T in types]...)
    rel_ids = tuple([_component_id(CS, T) for T in rel_types]...)

    num_ids = length(ids)
    use_map = num_ids >= 4 ? _UseMap() : _NoUseMap()

    M = max(1, cld(length(CS.parameters), 64))
    add_mask = _Mask{M}(ids...)
    rem_mask = _Mask{M}()

    world_has_rel = Val{_has_relations(CS)}()

    exprs = []
    push!(
        exprs,
        :(
            table_idx = _find_or_create_table!(
                world,
                world._tables[1],
                $ids,
                (),
                $rel_ids,
                targets,
                $add_mask,
                $rem_mask,
                $use_map,
                $world_has_rel,
            )[1]
        ),
    )
    push!(exprs, :(indices = _create_entities!(world, table_idx, n)))
    push!(exprs, :(table = world._tables[table_idx]))

    types_tuple_type_expr = Expr(:curly, :Tuple, [:($T) for T in types]...)
    ts_val_expr = :(Val{$(types_tuple_type_expr)}())
    push!(exprs,
        :(
            begin
                l = _lock(world._lock)
                columns = _get_columns(world, $ts_val_expr, table, indices...)
                fn(columns)

                batch = _BatchTable(table, world._archetypes[table.archetype], indices...)
                if _has_observers(world._event_manager, OnCreateEntity)
                    _fire_create_entities(world._event_manager, batch)
                end
                if _has_relations(table) && _has_observers(world._event_manager, OnAddRelations)
                    _fire_create_entities_relations(world._event_manager, batch)
                end
                _unlock(world._lock, l)
                return nothing
            end
        ),
    )

    push!(exprs, Expr(:return, :batch))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

@generated function _get_columns(
    world::W,
    ::Val{TS},
    table::_Table,
    start_idx::UInt32,
    end_idx::UInt32,
) where {W<:World,TS<:Tuple}
    CS = W.parameters[1]
    comp_types = TS.parameters
    world_storage_modes = W.parameters[3].parameters

    storage_modes = [
        world_storage_modes[_component_id(CS, T)]
        for T in comp_types
    ]

    exprs = Expr[]
    push!(exprs, :(entities = view(table.entities, start_idx:end_idx)))
    for i in 1:length(comp_types)
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        vec_sym = Symbol("vec", i)
        push!(exprs, :(@inbounds $stor_sym = _get_storage(world, $(comp_types[i]))))
        push!(exprs, :(@inbounds $col_sym = $stor_sym.data[Int(table.id)]))

        if storage_modes[i] == VectorStorage && fieldcount(comp_types[i]) > 0
            push!(exprs, :($vec_sym = FieldViewable(view($col_sym, start_idx:end_idx))))
        else
            push!(exprs, :($vec_sym = view($col_sym, start_idx:end_idx)))
        end
    end
    result_exprs = [:entities]
    for i in 1:length(comp_types)
        push!(result_exprs, Symbol("vec", i))
    end
    result_exprs = map(x -> :($x), result_exprs)
    push!(exprs, Expr(:return, Expr(:tuple, result_exprs...)))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end
