
"""
    Batch

A batch iterator.
This is returned from batch operations and serves for initializing newly added components.
"""
struct Batch{W<:World,TS<:Tuple,SM<:Tuple,N,M}
    _world::W
    _archetypes::Vector{_BatchArchetype{M}}
    _b_lock::_QueryLock
    _lock::UInt8
end

@generated function _Batch_from_types(
    world::W,
    archetypes::Vector{<:_BatchArchetype},
    ::Val{CT},
) where {W<:World,CT<:Tuple}
    comp_types = CT.parameters
    CS = W.parameters[1]
    M = max(1, cld(length(CS.parameters), 64))
    world_storage_modes = W.parameters[3].parameters

    # TODO: keeping this for now to make iteration consistent with queries
    storage_modes = [
        world_storage_modes[Int(_component_id(CS, T))]
        for T in comp_types
    ]
    comp_tuple_type = Expr(:curly, :Tuple, comp_types...)
    storage_tuple_mode = Expr(:curly, :Tuple, storage_modes...)

    return quote
        Batch{$W,$comp_tuple_type,$storage_tuple_mode,$(length(comp_types)),$M}(
            world,
            archetypes,
            _QueryLock(false),
            _lock(world._lock),
        )
    end
end

@inline function Base.iterate(b::Batch, state::Int)
    if state <= length(b._archetypes)
        result = _get_columns_at_index(b, state)
        return result, state + 1
    end
    close!(b)
    return nothing
end

@inline function Base.iterate(b::Batch)
    if b._b_lock.closed
        throw(InvalidStateException("batch closed, batches can't be used multiple times", :batch_closed))
    end
    b._b_lock.closed = true
    return Base.iterate(b, 1)
end

"""
    length(b::Batch)

Returns the number of entities in the batch.

Does not iterate or [close!](@ref close!(::Batch)) the batch.

!!! note

    The time complexity is linear with the number of archetypes in the batch.
    For batch entity creation, the number os archetype is always 1.
"""
function Base.length(b::Batch)
    count = 0
    for archetype in b._archetypes
        count += archetype.end_idx - archetype.start_idx + 1
    end
    count
end

"""
    close!(b::Batch)

Closes the batch iterator and unlocks the world.

Must be called if a batch is not fully iterated.
"""
function close!(b::Batch)
    # TODO: extend for different even types.
    # Note that for the other operations, the full list of archetypes is required.
    if _has_observers(b._world._event_manager, OnCreateEntity)
        _fire_create_entities(b._world._event_manager, b._archetypes[1])
    end
    b._b_lock.closed = true
    _unlock(b._world._lock, b._lock)
end

@generated function _get_columns_at_index(
    b::Batch{W,TS,SM,N,M},
    idx::Int,
) where {W<:World,TS<:Tuple,SM<:Tuple,N,M}
    storage_modes = SM.parameters
    comp_types = TS.parameters
    exprs = Expr[]
    push!(exprs, :(arch = b._archetypes[idx]))
    push!(exprs, :(entities = view(arch.archetype.entities, arch.start_idx:arch.end_idx)))
    for i in 1:N
        stor_sym = Symbol("stor", i)
        col_sym = Symbol("col", i)
        vec_sym = Symbol("vec", i)
        push!(exprs, :(@inbounds $stor_sym = _get_storage(b._world, $(comp_types[i]))))
        push!(exprs, :(@inbounds $col_sym = $stor_sym.data[Int(arch.archetype.id)]))

        if storage_modes[i] == VectorStorage && fieldcount(comp_types[i]) > 0
            push!(exprs, :($vec_sym = FieldViewable(view($col_sym, arch.start_idx:arch.end_idx))))
        else
            push!(exprs, :($vec_sym = view($col_sym, arch.start_idx:arch.end_idx)))
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

@generated function Base.eltype(::Type{Batch{W,TS,SM,N,M}}) where {W<:World,TS<:Tuple,SM<:Tuple,N,M}
    comp_types = TS.parameters
    storage_modes = SM.parameters

    result_types = Any[Entities]
    for i in 1:N
        T = comp_types[i]

        base_view = if fieldcount(comp_types[i]) == 0
            SubArray{T,1,Vector{T},Tuple{UnitRange{UInt32}},true}
        elseif storage_modes[i] == VectorStorage
            _FieldsViewable_type(Vector{T})
        else
            _StructArrayView_type(T, UnitRange{UInt32})
        end
        push!(result_types, base_view)
    end

    return Tuple{result_types...}
end

function Base.show(io::IO, batch::Batch{W,TS}) where {W<:World,TS<:Tuple}
    comp_types = TS.parameters
    type_names = join(map(_format_type, comp_types), ", ")

    entities = sum(arch.end_idx - arch.start_idx + 1 for arch in batch._archetypes)
    print(io, "Batch(entities=$entities, comp_types=($type_names))")
end
