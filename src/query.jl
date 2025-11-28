
mutable struct _QueryCursor
    tables::Vector{UInt32}
    closed::Bool
end

const _empty_relations = Pair{Int,Entity}[]

"""
    Query

A query for components. See function
[Query](@ref Query(::World,::Tuple;::Tuple,::Tuple,::Tuple,::Bool)) for details.
"""
struct Query{W<:World,TS<:Tuple,SM<:Tuple,EX,OPT,N,M}
    _mask::_Mask{M}
    _exclude_mask::_Mask{M}
    _world::W
    _archetypes::Vector{_Archetype{M}}
    _relations::Vector{Pair{Int,Entity}}
    _q_lock::_QueryCursor
    _lock::Int
    _has_excluded::Bool
end

"""
    Query(
        world::World,
        comp_types::Tuple;
        with::Tuple=(),
        without::Tuple=(),
        optional::Tuple=(),
        exclusive::Bool=false,
        relations::Tuple=(),
    )

Creates a query.

A query is an iterator for processing all entities that match the query's criteria.
The query itself iterates matching archetypes, while an inner loop or broadcast operations
must be used to manipulate individual entities (see example below).

A query [locks](@ref world-lock) the [World](@ref World) until it is fully iterated or closed manually.
This prevents structural changes like creating and removing entities or adding and removing components during the iteration.

See the user manual chapter on [Queries](@ref) for more details and examples.

# Arguments

  - `world`: The `World` instance to query.
  - `comp_types::Tuple`: Components the query filters for and provides access to.
  - `with::Tuple`: Additional components the entities must have.
  - `without::Tuple`: Components the entities must not have.
  - `optional::Tuple`: Additional components that are optional in the query.
  - `exclusive::Bool`: Makes the query exclusive in base and `with` components, can't be combined with `without`.
  - `relations::Tuple`: Relationship component type => target entity pairs.

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
for (entities, positions, velocities) in Query(world, (Position, Velocity))
    for i in eachindex(entities)
        pos = positions[i]
        vel = velocities[i]
        positions[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
end

# output

```
"""
Base.@constprop :aggressive function Query(
    world::World,
    comp_types::Tuple;
    with::Tuple=(),
    without::Tuple=(),
    optional::Tuple=(),
    exclusive::Bool=false,
    relations::Tuple{Vararg{Pair{DataType,Entity}}}=(),
)
    rel_types = ntuple(i -> Val(relations[i].first), length(relations))
    targets = ntuple(i -> relations[i].second, length(relations))
    return _Query_from_types(world,
        ntuple(i -> Val(comp_types[i]), length(comp_types)),
        ntuple(i -> Val(with[i]), length(with)),
        ntuple(i -> Val(without[i]), length(without)),
        ntuple(i -> Val(optional[i]), length(optional)),
        Val(exclusive),
        rel_types, targets,
    )
end

@generated function _Query_from_types(
    world::W,
    ::CT,
    ::WT,
    ::WO,
    ::OT,
    ::EX,
    ::TR,
    targets::Tuple{Vararg{Entity}},
) where {W<:World,CT<:Tuple,WT<:Tuple,WO<:Tuple,OT<:Tuple,EX<:Val,TR<:Tuple}
    world_storage_modes = W.parameters[3].parameters

    required_types = _to_types(CT)
    with_types = _to_types(WT)
    without_types = _to_types(WO)
    optional_types = _to_types(OT)
    rel_types = _to_types(TR)

    rel_ids = tuple([_component_id(W.parameters[1], T) for T in rel_types]...)

    # TODO: check relation components are actually relations

    # check for duplicates
    all_comps = vcat(required_types, with_types, without_types, optional_types)
    unique_comps = unique(all_comps)
    if length(all_comps) != length(unique_comps)
        duplicates = [x for x in unique_comps if count(==(x), all_comps) > 1]
        names = join(map(nameof, duplicates), ", ")
        throw(ArgumentError("duplicate component types in query: $names"))
    end

    comp_types = union(required_types, optional_types)
    non_exclude_types = union(comp_types, with_types)

    if EX === Val{true} && !isempty(without_types)
        throw(ArgumentError("cannot use 'exclusive' together with 'without'"))
    end

    CS = W.parameters[1]
    required_ids = map(C -> _component_id(CS, C), required_types)
    with_ids = map(C -> _component_id(CS, C), with_types)
    without_ids = map(C -> _component_id(CS, C), without_types)
    non_exclude_ids = map(C -> _component_id(CS, C), non_exclude_types)

    M = max(1, cld(length(CS.parameters), 64))
    mask = _Mask{M}(required_ids..., with_ids...)
    exclude_mask = EX === Val{true} ? _Mask{M}(_Not(), non_exclude_ids...) : _Mask{M}(without_ids...)
    has_excluded = (length(without_ids) > 0) || (EX === Val{true})

    storage_modes = [
        world_storage_modes[_component_id(W.parameters[1], T)]
        for T in comp_types
    ]
    comp_tuple_type = Expr(:curly, :Tuple, comp_types...)
    storage_tuple_mode = Expr(:curly, :Tuple, storage_modes...)

    ids_tuple = tuple(required_ids...)

    optional_flag_type_elts = [
        (T in optional_types) ? :(Val{true}) : :(Val{false})
        for T in comp_types
    ]
    optional_flags_type = Expr(:curly, :Tuple, optional_flag_type_elts...)

    archetypes = length(ids_tuple) == 0 ? :(world._archetypes) : :(_get_archetypes(world, $ids_tuple))

    return quote
        relations = if length(targets) > 0
            # TODO: can/should we use an ntuple instead?
            rel = Vector{Pair{Int,Entity}}()
            for (c, e) in zip($rel_ids, targets)
                push!(rel, c => e)
            end
            rel
        else
            _empty_relations
        end
        Query{$W,$comp_tuple_type,$storage_tuple_mode,$EX,$optional_flags_type,$(length(comp_types)),$M}(
            $(mask),
            $(exclude_mask),
            world,
            $(archetypes),
            relations,
            _QueryCursor(_empty_tables, false),
            _lock(world._lock),
            $(has_excluded),
        )
    end
end

function _get_archetypes(world::World, ids::Tuple{Vararg{Int}})
    comps = world._index.components
    rare_comp = @inbounds comps[ids[1]]
    min_len = length(rare_comp)
    @inbounds for i in 2:length(ids)
        comp = comps[ids[i]]
        comp_len = length(comp)
        if comp_len < min_len
            rare_comp, min_len = comp, comp_len
        end
    end
    return rare_comp
end

@inline function Base.iterate(q::Query, state::Tuple{Int,Int})
    arch, tab = state
    while arch <= length(q._archetypes)
        archetype = q._archetypes[arch]
        if tab == 0
            if isempty(archetype.tables.ids) ||
               !_contains_all(archetype.mask, q._mask) ||
               (q._has_excluded && _contains_any(archetype.mask, q._exclude_mask))
                arch += 1
                continue
            end

            if !_has_relations(archetype)
                table = q._world._tables[archetype.tables[1]]
                if isempty(table.entities)
                    arch += 1
                    continue
                end
                result = _get_columns(q, table)
                return result, (arch + 1, 0)
            end

            q._q_lock.tables = _get_tables(q._world, archetype, q._relations)
            tab = 1
        end

        while tab <= length(q._q_lock.tables)
            table = q._world._tables[q._q_lock.tables[tab]]
            # TODO we can probably optimize here if exactly one relation in archetype and one queries.
            if isempty(table.entities) || !_matches(q._world._relations, table, q._relations)
                tab += 1
                continue
            end
            result = _get_columns(q, table)
            return result, (arch, tab + 1)
        end

        arch += 1
        tab = 0
    end

    close!(q)
    return nothing
end

@inline function Base.iterate(q::Query)
    if q._q_lock.closed
        throw(InvalidStateException("query closed, queries can't be used multiple times", :batch_closed))
    end
    q._q_lock.closed = true

    return Base.iterate(q, (1, 0))
end

"""
    length(q::Query)

Returns the number of matching tables with at least one entity in the query.

Does not iterate or [close!](@ref close!(::Query)) the query.

!!! note

    The time complexity is linear with the number of tables in the query's pre-selection.
"""
function Base.length(q::Query)
    count = 0
    for archetype in q._archetypes
        if isempty(archetype.tables.ids) ||
           !_contains_all(archetype.mask, q._mask) ||
           (q._has_excluded && _contains_any(archetype.mask, q._exclude_mask))
            continue
        end

        if !_has_relations(archetype)
            table = q._world._tables[archetype.tables[1]]
            if isempty(table.entities)
                continue
            end
            count += 1
            continue
        end
        # TODO: count tables
        error("not implemented")
    end
    count
end

"""
    count_entities(q::Query)

Returns the number of matching entities in the query.

Does not iterate or [close!](@ref close!(::Query)) the query.

!!! note

    The time complexity is linear with the number of archetypes in the query's pre-selection.
    It is equivalent to iterating the query's archetypes and summing up their lengths.
"""
function count_entities(q::Query)
    count = 0
    for archetype in q._archetypes
        if isempty(archetype.tables.ids) ||
           !_contains_all(archetype.mask, q._mask) ||
           (q._has_excluded && _contains_any(archetype.mask, q._exclude_mask))
            continue
        end

        if !_has_relations(archetype)
            table = q._world._tables[archetype.tables[1]]
            count += length(table.entities)
            continue
        end
        # TODO: count tables
        error("not implemented")
    end
    count
end

"""
    close!(q::Query)

Closes the query and unlocks the world.

Must be called if a query is not fully iterated.
"""
function close!(q::Query)
    _unlock(q._world._lock, q._lock)
    q._q_lock.closed = true
    return nothing
end

@generated function _get_columns(
    q::Query{W,TS,SM,EX,OPT,N,M},
    table::_Table,
) where {W<:World,TS<:Tuple,SM<:Tuple,EX,OPT,N,M}
    comp_types = TS.parameters
    storage_modes = SM.parameters
    is_optional = OPT.parameters

    exprs = Expr[]
    push!(exprs, :(entities = table.entities))
    for i in 1:N
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        vec_sym = Symbol("vec", i)
        push!(exprs, :(@inbounds $stor_sym = _get_storage(q._world, $(comp_types[i]))))
        push!(exprs, :(@inbounds $col_sym = $stor_sym.data[table.id]))

        if is_optional[i] === Val{true}
            if storage_modes[i] == VectorStorage && fieldcount(comp_types[i]) > 0
                push!(exprs, :($vec_sym = length($col_sym) == 0 ? nothing : FieldViewable($col_sym)))
            else
                push!(exprs, :($vec_sym = length($col_sym) == 0 ? nothing : view($col_sym, :)))
            end
        else
            if storage_modes[i] == VectorStorage && fieldcount(comp_types[i]) > 0
                push!(exprs, :($vec_sym = FieldViewable($col_sym)))
            else
                push!(exprs, :($vec_sym = view($col_sym, :)))
            end
        end
    end
    result_exprs = [:entities]
    for i in 1:N
        push!(result_exprs, Symbol("vec", i))
    end

    element_type = Base.eltype(Query{W,TS,SM,EX,OPT,N,M})

    result_exprs = map(x -> :($x), result_exprs)
    tuple_expr = Expr(:tuple, result_exprs...)
    push!(exprs, Expr(:return, Expr(:(::), tuple_expr, element_type)))

    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

Base.IteratorSize(::Type{<:Query}) = Base.SizeUnknown()

@generated function Base.eltype(::Type{Query{W,TS,SM,EX,OPT,N,M}}) where {W<:World,TS<:Tuple,SM<:Tuple,EX,OPT,N,M}
    comp_types = TS.parameters
    storage_modes = SM.parameters
    is_optional = OPT.parameters

    result_types = Any[Entities]
    for i in 1:N
        T = comp_types[i]

        base_view = if fieldcount(comp_types[i]) == 0
            SubArray{T,1,Vector{T},Tuple{Base.Slice{Base.OneTo{Int}}},true}
        elseif storage_modes[i] == VectorStorage
            _FieldsViewable_type(Vector{T})
        else
            _StructArrayView_type(T, UnitRange{Int})
        end

        opt_flag = is_optional[i] === Val{true}
        push!(result_types, opt_flag ? Union{Nothing,base_view} : base_view)
    end

    return Tuple{result_types...}
end

function Base.show(io::IO, query::Query{W,CT,SM,EX}) where {W<:World,CT<:Tuple,SM<:Tuple,EX<:Val}
    world_types = W.parameters[2].parameters
    comp_types = CT.parameters

    mask_ids = _active_bit_indices(query._mask)
    mask_types = tuple(map(i -> world_types[Int(i)].parameters[1], mask_ids)...)

    required_types = intersect(mask_types, comp_types)
    optional_types = setdiff(comp_types, mask_types)
    with_types = setdiff(mask_types, comp_types)

    required_names = join(map(_format_type, required_types), ", ")
    optional_names = join(map(_format_type, optional_types), ", ")
    with_names = join(map(_format_type, with_types), ", ")
    is_exclusive = EX === Val{true}

    excl_types = ()
    without_names = ""
    if !is_exclusive
        excl_ids = _active_bit_indices(query._exclude_mask)
        excl_types = tuple(map(i -> world_types[Int(i)].parameters[1], excl_ids)...)
        without_names = join(map(_format_type, excl_types), ", ")
    end

    kw_parts = String[]
    if !isempty(optional_types)
        push!(kw_parts, "optional=($optional_names)")
    end
    if !isempty(with_types)
        push!(kw_parts, "with=($with_names)")
    end
    if !isempty(excl_types)
        push!(kw_parts, "without=($without_names)")
    end
    if is_exclusive
        push!(kw_parts, "exclusive=true")
    end

    if isempty(kw_parts)
        print(io, "Query(($required_names))")
    else
        print(io, "Query(($required_names); ", join(kw_parts, ", "), ")")
    end
end
