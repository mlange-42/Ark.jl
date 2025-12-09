
"""
    new_entities!(
        world::World,
        n::Int, 
        defaults::Tuple;
        relations:Tuple=(),
        iterate::Bool=false,
    )::Union{Batch,Nothing}

Creates the given number of [`Entity`](@ref), initialized with default values.
Component types are inferred from the provided default values.

If `iterate` is true, a [`Batch`](@ref) iterator over the newly created entities is returned
that can be used for initialization.

See also [new_entities!](@ref new_entities!(::World, ::Int, ::Tuple)) for creating entities from component types.

# Arguments

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
for (entities, positions, velocities) in new_entities!(world, 100, (Position(0, 0), Velocity(1, 1)); iterate=true)
    for i in eachindex(entities)
        positions[i] = Position(rand(), rand())
    end
end

# output

```
"""
Base.@constprop :aggressive function new_entities!(
    world::World,
    n::Int,
    defaults::Tuple;
    relations::Tuple{Vararg{Pair{DataType,Entity}}}=(),
    iterate::Bool=false,
)
    rel_types = ntuple(i -> Val(relations[i].first), length(relations))
    targets = ntuple(i -> relations[i].second, length(relations))
    return _new_entities_from_defaults!(world, UInt32(n),
        Val{typeof(defaults)}(), defaults,
        rel_types, targets, iterate)
end

Base.@constprop :aggressive function new_entities!(
    world::World,
    n::Int,
    defaults::Tuple{};
    iterate::Bool=false,
)
    return _new_entities_from_defaults!(world, UInt32(n),
        Val{typeof(defaults)}(), defaults,
        (), (), iterate)
end

"""
    new_entities!(
        world::World,
        n::Int,
        comp_types::Tuple;
        relations:Tuple=(),
    )::Batch

Creates the given number of [`Entity`](@ref).

Returns a [`Batch`](@ref) iterator over the newly created entities that should be used to initialize components.
Note that components are not initialized/undef unless set in the iterator!

See also [new_entities!](@ref new_entities!(::World, ::Int, ::Tuple; ::Bool)) for creating entities from default values.

# Arguments

  - `world::World`: The `World` instance to use.
  - `n::Int`: The number of entities to create.
  - `comp_types::Tuple`: Component types for the new entities, like `(Position, Velocity)`.
  - `relations::Tuple`: Relationship component type => target entity pairs.

# Example

Create 100 entities from component types and initialize them:

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
for (entities, positions, velocities) in new_entities!(world, 100, (Position, Velocity))
    for i in eachindex(entities)
        positions[i] = Position(rand(), rand())
        velocities[i] = Velocity(1, 1)
    end
end

# output

```
"""
Base.@constprop :aggressive function new_entities!(
    world::World,
    n::Int,
    comp_types::Tuple{Vararg{DataType}};
    relations::Tuple{Vararg{Pair{DataType,Entity}}}=(),
)
    rel_types = ntuple(i -> Val(relations[i].first), length(relations))
    targets = ntuple(i -> relations[i].second, length(relations))
    return _new_entities_from_types!(world, UInt32(n),
        ntuple(i -> Val(comp_types[i]), length(comp_types)),
        rel_types, targets)
end

function _get_tables(
    world::World,
    arches::Vector{_Archetype{M}},
    arches_hot::Vector{_ArchetypeHot{M}},
    filter::F,
)::Tuple{Vector{_Table},Bool} where {M,F<:Filter}
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
            push!(tables, table)
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
                push!(tables, table)
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
    remove_entities!(world, filter) do entities
    end
end

@generated function remove_entities!(fn::Fn, world::W, filter::F) where {Fn,W<:World,F<:Filter}
    CS = W.parameters[1]
    TS = F.parameters[2]
    OPT = F.parameters[4]

    comp_types = _to_types(TS.parameters)
    optional_flags = OPT.parameters

    required_ids = [_component_id(CS, comp_types[i]) for i in 1:length(comp_types) if optional_flags[i] === Val{false}]
    ids_tuple = tuple(required_ids...)

    archetypes =
        length(ids_tuple) == 0 ? :((world._archetypes, world._archetypes_hot)) :
        :(_get_archetypes(world, $ids_tuple))

    world_has_rel = _has_relations(CS)
    quote
        _check_locked(world)

        arches, arches_hot = $archetypes
        # TODO: make separate path for cached filters.
        tables, any_relations = _get_tables(world, arches, arches_hot, filter)

        for table in tables
            fn(table.entities)
        end

        l = _lock(world._lock)

        if _has_observers(world._event_manager, OnRemoveEntity)
            for table in tables
                _fire_remove_entities(
                    world._event_manager,
                    table,
                    world._archetypes_hot[table.archetype].mask,
                )
            end
        end
        if any_relations && _has_observers(world._event_manager, OnRemoveRelations)
            for table in tables
                if _has_relations(table)
                    _fire_remove_entities_relations(
                        world._event_manager,
                        table,
                        world._archetypes_hot[table.archetype].mask,
                    )
                end
            end
        end

        _unlock(world._lock, l)

        cleanup = world._pool.entities
        for table in tables
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

        resize!(tables, 0)
        resize!(cleanup, 0)

        return nothing
    end
end

@generated function _new_entities_from_defaults!(
    world::W,
    n::UInt32,
    ::Val{TS},
    values::Tuple,
    ::TR,
    targets::Tuple{Vararg{Entity}},
    iterate::Bool,
) where {W<:World,TS<:Tuple,TR<:Tuple}
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
    push!(
        exprs,
        :(
            if iterate
                batch = _Batch_from_types(
                    world,
                    [_BatchTable(table, world._archetypes[table.archetype], indices...)],
                    $ts_val_expr,
                )
                return batch
            else
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

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

@generated function _new_entities_from_types!(
    world::W,
    n::UInt32,
    ::TS,
    ::TR,
    targets::Tuple{Vararg{Entity}},
) where {W<:World,TS<:Tuple,TR<:Tuple}
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
            batch = _Batch_from_types(
                world,
                [_BatchTable(table, world._archetypes[table.archetype], indices[1], indices[2])],
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
