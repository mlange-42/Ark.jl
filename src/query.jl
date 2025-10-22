
"""
    Query{W,CS,N}

A query for N components.
"""
mutable struct Query{W<:World,CS<:Tuple,N}
    _index::Int
    _world::W
    _ids::NTuple{N,UInt8}
    _mask::_Mask
    _exclude_mask::_Mask
    _has_excluded::Bool
    _storage::CS
    _lock::UInt8
end

# TODO: this could also be generated
"""
    Query(
        world::World,
        comp_types::Tuple{Vararg{DataType}};
        with::Tuple{Vararg{DataType}}=(),
        without::Tuple{Vararg{DataType}}=(),
        optional::Tuple{Vararg{DataType}}=(),
    )

Creates a query.

# Arguments
- `world::World`: The world to use for this query.
- `comp_types::Tuple{Vararg{DataType}}`: Components the query filters for and that it provides access to.
- `with::Tuple{Vararg{DataType}}`: Additional components the entities must have.
- `without::Tuple{Vararg{DataType}}`: Components the entities must not have.
- `optional::Tuple{Vararg{DataType}}`: Makes components of the parameters optional.
"""
function Query(
    world::W,
    comp_types::Tuple{Vararg{DataType}};
    with::Tuple{Vararg{DataType}}=(),
    without::Tuple{Vararg{DataType}}=(),
    optional::Tuple{Vararg{DataType}}=(),
) where {W<:World}
    ids = Tuple(_component_id(world, C) for C in comp_types)
    with_ids = Tuple(_component_id(world, C) for C in with)
    without_ids = Tuple(_component_id(world, C) for C in without)
    optional_ids = Tuple(_component_id(world, C) for C in optional)

    mask = _Mask(ids..., with_ids...)
    if !isempty(optional)
        mask = _clear_bits(mask, _Mask(optional_ids...))
    end

    return _Query_from_types(world, Val{Tuple{comp_types...}}(), ids, mask, _Mask(without_ids...), !isempty(without))
end

@generated function _Query_from_types(
    world::W,
    ::Val{CT},
    ids::NTuple{N,UInt8},
    mask::_Mask,
    exclude_mask::_Mask,
    has_excluded::Bool,
) where {W<:World,CT<:Tuple,N}
    types = CT.parameters

    storage_exprs = Expr[:(_get_storage(world, $(QuoteNode(T)))) for T in types]
    storages_tuple = Expr(:tuple, storage_exprs...)

    storage_types = [:(_ComponentStorage{$(QuoteNode(T))}) for T in types]
    storage_tuple_type = :(Tuple{$(storage_types...)})

    return quote
        Query{$W,$storage_tuple_type,$N}(
            0,
            world,
            ids,
            mask,
            exclude_mask,
            has_excluded,
            $storages_tuple,
            UInt8(0),
        )
    end
end

"""
    Base.getindex(q::Query{W,CS,N}) where {W<:World,CS<:Tuple,N}

Returns the component columns of the archetype at the current cursor position.
"""
@inline function Base.getindex(q::Query{W,CS,N}) where {W<:World,CS<:Tuple,N}
    return _get_query_archetypes(q)
end

@inline function Base.iterate(q::Query{W,CS}, state::Tuple{Int,Int}) where {W<:World,CS<:Tuple}
    logical_index, physical_index = state
    q._index = physical_index

    while q._index <= length(q._world._archetypes)
        archetype = q._world._archetypes[q._index]
        if length(archetype.entities) > 0 &&
           _contains_all(archetype.mask, q._mask) &&
           !(q._has_excluded && _contains_any(archetype.mask, q._exclude_mask))
            result = logical_index
            next_state = (logical_index + 1, q._index + 1)
            return result, next_state
        end
        q._index += 1
    end

    close(q)
    return nothing
end

@inline function Base.iterate(q::Query{W,CS}) where {W<:World,CS<:Tuple}
    q._lock = _lock(q._world._lock)
    return Base.iterate(q, (1, 1))
end

"""
    close(q::Query)

Closes the query and unlocks the world.

Must be called if a query is not fully iterated.
"""
function close(q::Query{W,CS}) where {W<:World,CS<:Tuple}
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

"""
    entities(q::Query)

Returns the entities of the current archetype.
"""
function entities(q::Query{W,CS})::Column{Entity} where {W<:World,CS<:Tuple}
    return q._world._archetypes[q._index].entities
end

@generated function _get_query_archetypes(q::Query{W,CS,N}) where {W<:World,CS<:Tuple,N}
    exprs = Expr[]
    for i in 1:N
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        push!(exprs, :($stor_sym = Base.getfield(q._storage, $i)))
        push!(exprs, :($col_sym = $stor_sym.data[q._index]))
    end
    result_syms = [Symbol("col", i) for i in 1:N]
    push!(exprs, Expr(:return, Expr(:tuple, result_syms...)))
    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end
