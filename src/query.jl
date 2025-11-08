
mutable struct _QueryLock
    closed::Bool
end

"""
    Query

A query for components.
"""
struct Query{W<:World,TS<:Tuple,SM<:Tuple,N,M}
    _mask::_Mask{M}
    _exclude_mask::_Mask{M}
    _world::W
    _archetypes::Vector{_Archetype{M}}
    _q_lock::_QueryLock
    _lock::UInt8
    _has_excluded::Bool
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
        world_storage_modes[Int(_component_id(W.parameters[1], T))]
        for T in comp_types
    ]
    comp_tuple_type = Expr(:curly, :Tuple, comp_types...)
    storage_tuple_mode = Expr(:curly, :Tuple, storage_modes...)

    ids_tuple = tuple(required_ids...)

    return quote
        Query{$W,$comp_tuple_type,$storage_tuple_mode,$(length(comp_types)),$M}(
            $(mask),
            $(exclude_mask),
            world,
            _get_archetypes(world, $ids_tuple),
            _QueryLock(false),
            _lock(world._lock),
            $(has_excluded ? true : false),
        )
    end
end

function _get_archetypes(world::World, ids::Tuple{Vararg{UInt8}})
    if length(ids) == 0
        return world._archetypes
    else
        comps = world._index.components
        rare_component = argmin(length(comps[i]) for i in ids)
        return comps[ids[rare_component]]
    end
end

@inline function Base.iterate(q::Query, state::Int)
    while state <= length(q._archetypes)
        archetype = q._archetypes[state]
        if length(archetype.entities) > 0 &&
           _contains_all(archetype.mask, q._mask) &&
           !(q._has_excluded && _contains_any(archetype.mask, q._exclude_mask))
            result = _get_columns(q, state)
            if isnothing(result)
                return result, state + 1
            else
                return result, state + 1
            end
        end
        state += 1
    end

    close!(q)
    return nothing
end

@inline function Base.iterate(q::Query)
    if q._q_lock.closed
        throw(InvalidStateException("query closed, queries can't be used multiple times", :batch_closed))
    end
    q._q_lock.closed = true

    return Base.iterate(q, 1)
end

"""
    close!(q::Query)

Closes the query and unlocks the world.

Must be called if a query is not fully iterated.
"""
function close!(q::Query)
    _unlock(q._world._lock, q._lock)
    q._q_lock.closed = true
end

@generated function _get_columns(
    q::Query{W,TS,SM,N},
    idx::Int,
) where {W<:World,TS<:Tuple,SM<:Tuple,N}
    comp_types = TS.parameters
    storage_modes = SM.parameters
    exprs = Expr[]
    push!(exprs, :(archetype = q._archetypes[idx]))
    push!(exprs, :(entities = archetype.entities))
    for i in 1:N
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        vec_sym = Symbol("vec", i)
        push!(exprs, :(@inbounds $stor_sym = _get_storage(q._world, $(comp_types[i]))))
        push!(exprs, :(@inbounds $col_sym = $stor_sym.data[archetype.id]))

        if isbitstype(comp_types[i]) && storage_modes[i] == VectorStorage
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
