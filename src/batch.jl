struct _BatchArchetype
    archetype::_Archetype
    start_idx::UInt32
    end_idx::UInt32
end

"""
    Batch

A batch iterator.
This is returned from batch operations and serves for initializing newly added components.
"""
mutable struct Batch{W<:World,CS<:Tuple,N}
    _world::W
    _archetypes::Vector{_BatchArchetype}
    _storages::CS
    _index::Int
    _lock::UInt8
end

@generated function _Batch_from_types(
    world::W,
    archetypes::Vector{_BatchArchetype},
    ::Val{CT},
) where {W<:World,CT<:Tuple}
    comp_types = CT.parameters

    storage_exprs = Expr[:(_get_storage(world, $T)) for T in comp_types]
    storages_tuple = Expr(:tuple, storage_exprs...)

    storage_types = [:(_ComponentStorage{$T}) for T in comp_types]
    storage_tuple_type = :(Tuple{$(storage_types...)})

    return quote
        Batch{$W,$storage_tuple_type,$(length(comp_types))}(
            world,
            archetypes,
            $storages_tuple,
            0,
            _lock(world._lock),
        )
    end
end

@inline function Base.iterate(b::Batch, state::Int)

    if state <= length(b._archetypes)
        result = _get_columns_at_index(b)
        b._index = state
        next_state = state + 1
        return result, next_state
    end

    close!(b)
    return nothing
end

@inline function Base.iterate(b::Batch)
    if b._lock == 0
        error("batch closed, batches can't be used multiple times")
    end
    return Base.iterate(b, 1)
end

"""
    close!(b::Batch)

Closes the batch iterator and unlocks the world.

Must be called if a batch is not fully iterated.
"""
function close!(b::Batch)
    _unlock(b._world._lock, b._lock)
    b._index = 0
    b._lock = 0
end

@generated function _get_columns_at_index(b::Batch{W,CS,N}) where {W<:World,CS<:Tuple,N}
    exprs = Expr[]
    push!(exprs, :(arch = b._archetypes[b._index]))
    push!(exprs, :(entities = view(arch.archetype.entities, arch.start_idx:arch.end_idx)))
    for i in 1:N
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        vec_sym = Symbol("vec", i)
        push!(exprs, :($stor_sym = b._storages.$i))
        push!(exprs, :($col_sym = $stor_sym.data[Int(arch.archetype.id)]))
        # TODO: return nothing if the component is not present.
        # Required for optional components. Should we remove optional?
        push!(exprs, :($vec_sym = $col_sym === nothing ? nothing : view($col_sym, arch.start_idx:arch.end_idx)))
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
