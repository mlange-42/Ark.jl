
mutable struct Query{CS<:Tuple, N}
    _index::Int
    _world::World
    _ids::NTuple{N, UInt8}
    _mask::_Mask
    _exclude_mask::_Mask
    _has_excluded::Bool
    _storage::CS
    _lock::UInt8
end

function Query(
    world::World, CompsTypes::Tuple;
    with::Tuple{Vararg{DataType}} = (),
    without::Tuple{Vararg{DataType}} = (),
    optional::Tuple{Vararg{DataType}} = (),
)
    ids = Tuple(_component_id!(world, C) for C in CompsTypes)
    with_ids = map(x -> _component_id!(world, x), with)
    without_ids = map(x -> _component_id!(world, x), without)
    mask = _Mask(ids..., with_ids...)
    if length(optional) > 0
        opt_ids = map(x -> _component_id!(world, x), optional)
        mask = _clear_bits(mask, _Mask(opt_ids...))
    end
    return Query1{A}(
        0,
        world,
        ids,
        mask,
        _Mask(without_ids...),
        length(without_ids) > 0,
        Tuple(_get_storage(world, id, C) for (id, C) in zip(ids,CompsTypes)),
        0,
    )
end

@generated function get_query_components(q::Query{CS}) where {CS <: Tuple}
    N = length(CS.parameters)
    expressions = [:(q._storage[$i].data[q._index]) for i in 1:N]
    return Expr(:tuple, expressions...)
end

@inline function get_components(q::Query)::Tuple{Union{Nothing,Column}}
    return q[]
end

@inline function Base.getindex(q::Query)::Tuple{Union{Nothing,Column}}
    return get_query_components(q)
end

@inline function Base.iterate(q::Query, state::Tuple{Int,Int})
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

@inline function Base.iterate(q::Query)
    q._lock = _lock(q._world._lock)
    return Base.iterate(q, (1, 1))
end

function close(q::Query)
    q._index = 0
    _unlock(q._world._lock, q._lock)
end

function entities(q::Query)::Column{Entity}
    return q._world._archetypes[q._index].entities
end
