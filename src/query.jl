
mutable struct _Cursor
    _archetypes::Vector{_Archetype}
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
        comp_types::Tuple;
        with::Tuple=(),
        without::Tuple=(),
        optional::Tuple=(),
        exclusive::Bool=false
    )

Creates a query.

Macro version of [`Query`](@ref) that allows ergonomic construction of queries using simulated keyword arguments.

Queries can be stored and re-used. However, query creation is fast (<20ns), so this is not mandatory.

# Arguments

  - `world`: The `World` instance to query.
  - `comp_types::Tuple`: Components the query filters for and provides access to. Must be a literal tuple like `(Position, Velocity)`.
  - `with::Tuple`: Additional components the entities must have. Passed as `with=(Health,)`.
  - `without::Tuple`: Components the entities must not have. Passed as `without=(Altitude,)`.
  - `optional::Tuple`: Components that are optional in the query. Passed as `optional=(Velocity,)`.
  - `exclusive::Bool`: Makes the query exclusive in base and `with` components, can't be combined with `without`.

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
for (entities, positions, velocities) in @Query(world, (Position, Velocity))
    for i in eachindex(entities)
        pos = positions[i]
        vel = velocities[i]
        positions[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
end

# output

```
"""
macro Query(world_expr, comp_types_expr)
    :(Query($(esc(world_expr)), Val.($(esc(comp_types_expr)))))
end
macro Query(kwargs_expr::Expr, world_expr, comp_types_expr)
    map(x -> (x.args[2] = :(Val.($(x.args[2])))), kwargs_expr.args)
    quote
        Query(
            $(esc(world_expr)),
            Val.($(esc(comp_types_expr)));
            $(esc.(kwargs_expr.args)...),
        )
    end
end

"""
    Query(
        world::World,
        comp_types::Tuple;
        with::Tuple=(),
        without::Tuple=(),
        optional::Tuple=(),
        exclusive::Val=Val(false)
    )

Creates a query.

Queries can be stored and re-used. However, query creation is fast (<20ns), so this is not mandatory.

For a more convenient tuple syntax, the macro [`@Query`](@ref) is provided.

# Arguments

  - `world::World`: The world to use for this query.
  - `comp_types::Tuple`: Components the query filters for and that it provides access to.
  - `with::Tuple`: Additional components the entities must have.
  - `without::Tuple`: Components the entities must not have.
  - `optional::Tuple`: Makes components of the parameters optional.
  - `exclusive::Val{Bool}`: Makes the query exclusive in base and `with` components, can't be combined with `without`.

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
for (entities, positions, velocities) in Query(world, Val.((Position, Velocity)))
    for i in eachindex(entities)
        pos = positions[i]
        vel = velocities[i]
        positions[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
end

# output

```
"""
function Query(
    world::World,
    comp_types::Tuple;
    with::Tuple=(),
    without::Tuple=(),
    optional::Tuple=(),
    exclusive::Val=Val(false),
)
    return _Query_from_types(world, comp_types, with, without, optional, exclusive)
end

@generated function _Query_from_types(
    world::W,
    ::CT,
    ::WT,
    ::WO,
    ::OT,
    ::EX,
) where {W<:World,CT<:Tuple,WT<:Tuple,WO<:Tuple,OT<:Tuple,EX<:Val}
    world_storage_modes = W.parameters[3].parameters

    comp_types = _try_to_types(CT)
    with_types = _try_to_types(WT)
    without_types = _try_to_types(WO)
    optional_types = _try_to_types(OT)

    required_types = setdiff(comp_types, optional_types)
    non_exclude_types = union(comp_types, with_types)

    if EX === Val{true} && !isempty(without_types)
        throw(ArgumentError("cannot use 'exclusive' together with 'without'"))
    end

    function get_id(C)
        _component_id(W.parameters[1], C)
    end

    all_ids = map(get_id, comp_types)
    required_ids = map(get_id, required_types)
    with_ids = map(get_id, with_types)
    without_ids = map(get_id, without_types)
    non_exclude_ids = map(get_id, non_exclude_types)

    mask = _Mask(required_ids..., with_ids...)
    exclude_mask = EX === Val{true} ? _MaskNot(non_exclude_ids...) : _Mask(without_ids...)
    has_excluded = (length(without_ids) > 0) || (EX === Val{true})

    storage_types = [
        world_storage_modes[Int(_component_id(W.parameters[1], T))] == StructArrayStorage ?
        _ComponentStorage{T,_StructArray_type(T)} :
        _ComponentStorage{T,Vector{T}}
        for T in comp_types
    ]
    storage_tuple_type = Expr(:curly, :Tuple, storage_types...)

    storage_exprs = Expr[:(world._storages[$(Int(i))]) for i in all_ids]
    storages_tuple = Expr(:tuple, storage_exprs...)

    ids_tuple = tuple(required_ids...)

    return quote
        Query{$W,$storage_tuple_type,$(length(comp_types)),$(length(required_types))}(
            world,
            _Cursor(world._archetypes, UInt8(0)),
            $ids_tuple,
            $(mask),
            $(exclude_mask),
            $(has_excluded ? true : false),
            $storages_tuple,
        )
    end
end

@inline function Base.iterate(q::Query, state::Int)
    while state <= length(q._cursor._archetypes)
        archetype = q._cursor._archetypes[state]
        if length(archetype.entities) > 0 &&
           _contains_all(archetype.mask, q._mask) &&
           !(q._has_excluded && _contains_any(archetype.mask, q._exclude_mask))
            result = _get_columns(q, archetype)
            return result, state + 1
        end
        state += 1
    end

    close!(q)
    return nothing
end

@inline function Base.iterate(q::Query)
    if length(q._ids) != 0
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
function close!(q::Query)
    _unlock(q._world._lock, q._cursor._lock)
end

@generated function _get_columns(q::Query{W,CS,N,NR}, archetype::_Archetype) where {W<:World,CS<:Tuple,N,NR}
    storage_types = CS.parameters
    exprs = Expr[]
    push!(exprs, :(entities = archetype.entities))
    for i in 1:N
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        vec_sym = Symbol("vec", i)
        push!(exprs, :($stor_sym = q._storage.$i))
        push!(exprs, :($col_sym = $stor_sym.data[archetype.id]))

        if isbitstype(storage_types[i].parameters[1]) && !(storage_types[i].parameters[2] <: _StructArray)
            push!(exprs, :($vec_sym = length($col_sym) == 0 ? nothing : _new_fields_view(view($col_sym, :))))
        else
            push!(exprs, :($vec_sym = length($col_sym) == 0 ? nothing : view($col_sym, :)))
        end
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
