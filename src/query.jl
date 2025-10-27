
mutable struct _Cursor
    _archetypes::Vector{_Archetype}
    _index::Int
    _lock::UInt8
end

"""
    Query

A query for components.
"""
struct Query{W<:World,CS<:Tuple,N,NR}
    _world::W
    _cursor::_Cursor
    _ids::NTuple{NR,UInt8}
    _mask::_Mask
    _exclude_mask::_Mask
    _has_excluded::Bool
    _storage::CS
end

"""
    @Query(
        world::World,
        comp_types::Tuple,
        with::Tuple=(),
        without::Tuple=(),
        optional::Tuple=()
    )

Creates a query.

Macro version of [`Query`](@ref) that allows ergonomic construction of queries using simulated keyword arguments.

Queries can be stored and re-used. However, query creation is fast (<20ns), so this is mandatory.

# Arguments
- `world`: The `World` instance to query.
- `comp_types::Tuple`: Components the query filters for and provides access to. Must be a literal tuple like `(Position, Velocity)`.
- `with::Tuple`: Additional components the entities must have. Passed as `with=(Health,)`.
- `without::Tuple`: Components the entities must not have. Passed as `without=(Altitude,)`.
- `optional::Tuple`: Components that are optional in the query. Passed as `optional=(Velocity,)`.

# Example
```julia
@Query(world, (Position, Velocity), with=(Health,), without=(Altitude,))
```
"""
macro Query(args...)
    if length(args) < 2
        error("@Query requires at least a world and component tuple")
    end

    world_expr = args[1]
    comp_types_expr = args[2]

    # Default values
    with_expr = :(())
    without_expr = :(())
    optional_expr = :(())

    # Parse simulated keyword arguments
    for arg in args[3:end]
        if Base.isexpr(arg, :(=), 2)
            name, value = arg.args
            if name == :with
                with_expr = value
            elseif name == :without
                without_expr = value
            elseif name == :optional
                optional_expr = value
            else
                error("Unknown keyword argument: $name")
            end
        else
            error("Unexpected argument format: $arg")
        end
    end

    quote
        Query(
            $(esc(world_expr)),
            Val.($(esc(comp_types_expr)));
            with=Val.($(esc(with_expr))),
            without=Val.($(esc(without_expr))),
            optional=Val.($(esc(optional_expr)))
        )
    end
end

"""
    Query(
        world::World,
        comp_types::Tuple;
        with::Tuple=(),
        without::Tuple=(),
        optional::Tuple=()
    )

Creates a query.

Queries can be stored and re-used. However, query creation is fast (<20ns), so this is mandatory.

For a more convenient tuple syntax, the macro [`@Query`](@ref) is provided.

# Arguments
- `world::World`: The world to use for this query.
- `comp_types::Tuple`: Components the query filters for and that it provides access to.
- `with::Tuple`: Additional components the entities must have.
- `without::Tuple`: Components the entities must not have.
- `optional::Tuple`: Makes components of the parameters optional.

# Example
```julia
Query(world, Val.((Position, Velocity)), with=Val.((Health,)), without=Val.((Altitude,)))
```
"""
function Query(
    world::W,
    comp_types::Tuple;
    with::Tuple=(),
    without::Tuple=(),
    optional::Tuple=()
) where {W<:World}
    return _Query_from_types(world, comp_types, with, without, optional)
end

@generated function _Query_from_types(
    world::W,
    ::CT,
    ::WT,
    ::WO,
    ::OT
) where {W<:World,CT<:Tuple,WT<:Tuple,WO<:Tuple,OT<:Tuple}
    # Extract actual types from each tuple
    comp_types = [x.parameters[1] for x in CT.parameters]
    with_types = [x.parameters[1] for x in WT.parameters]
    without_types = [x.parameters[1] for x in WO.parameters]
    optional_types = [x.parameters[1] for x in OT.parameters]

    required_types = setdiff(comp_types, optional_types)

    # Component IDs
    id_exprs = Expr[:(_component_id(world, $(QuoteNode(T)))) for T in required_types]
    ids_tuple = Expr(:tuple, id_exprs...)

    with_ids_exprs = Expr[:(_component_id(world, $(QuoteNode(T)))) for T in with_types]
    without_ids_exprs = Expr[:(_component_id(world, $(QuoteNode(T)))) for T in without_types]

    # Mask construction
    mask_expr = :(_Mask($(id_exprs...), $(with_ids_exprs...)))

    exclude_mask_expr = :(_Mask($(without_ids_exprs...)))
    has_excluded_expr = :($(length(without_types) > 0))

    # Storage construction
    storage_exprs = Expr[:(_get_storage(world, $(QuoteNode(T)))) for T in comp_types]
    storages_tuple = Expr(:tuple, storage_exprs...)

    storage_types = [:(_ComponentStorage{$(QuoteNode(T))}) for T in comp_types]
    storage_tuple_type = :(Tuple{$(storage_types...)})

    return quote
        Query{$W,$storage_tuple_type,$(length(comp_types)),$(length(required_types))}(
            world,
            _Cursor(world._archetypes, 0, UInt8(0)),
            $ids_tuple,
            $mask_expr,
            $exclude_mask_expr,
            $has_excluded_expr,
            $storages_tuple,
        )
    end
end

@inline function Base.iterate(q::Query{W,CS}, state::Int) where {W<:World,CS<:Tuple}
    q._cursor._index = state

    while q._cursor._index <= length(q._cursor._archetypes)
        archetype = q._cursor._archetypes[q._cursor._index]
        if length(archetype.entities) > 0 &&
           _contains_all(archetype.mask, q._mask) &&
           !(q._has_excluded && _contains_any(archetype.mask, q._exclude_mask))
            result = _get_columns_at_index(q)
            next_state = q._cursor._index + 1
            return result, next_state
        end
        q._cursor._index += 1
    end

    close!(q)
    return nothing
end

@inline function Base.iterate(q::Query{W,CS}) where {W<:World,CS<:Tuple}
    if length(q._ids) == 0
        q._cursor._archetypes = q._world._archetypes
    else
        comps = q._world._index.components
        rare_component = argmin(length(comps[i]) for i in q._ids)
        q._cursor._archetypes = comps[rare_component]
    end
    q._cursor._lock = _lock(q._world._lock)
    return Base.iterate(q, 1)
end

"""
    close!(q::Query)

Closes the query and unlocks the world.

Must be called if a query is not fully iterated.
"""
function close!(q::Query{W,CS}) where {W<:World,CS<:Tuple}
    q._cursor._index = 0
    _unlock(q._world._lock, q._cursor._lock)
end

@generated function _get_columns_at_index(q::Query{W,CS,N}) where {W<:World,CS<:Tuple,N}
    exprs = Expr[]
    push!(exprs, :(archetype = q._cursor._archetypes[q._cursor._index]))
    push!(exprs, :(entities = archetype.entities))
    for i in 1:N
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        vec_sym = Symbol("vec", i)
        push!(exprs, :($stor_sym = q._storage.$i))
        push!(exprs, :($col_sym = $stor_sym.data[archetype.id]))
        # TODO: return nothing if the component is not present.
        # Required for optional components. Should we remove optional?
        push!(exprs, :($vec_sym = $col_sym === nothing ? nothing : $col_sym._data))
    end
    result_exprs = [:entities]
    for i in 1:N
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
