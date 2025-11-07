
"""
    Batch

A batch iterator.
This is returned from batch operations and serves for initializing newly added components.
"""
struct Batch{W<:World,TS<:Tuple,SM<:Tuple,N}
    _world::W
    _archetypes::Vector{_BatchArchetype}
    _handle::Entity
    _lock::UInt8
end

@generated function _Batch_from_types(
    world::W,
    archetypes::Vector{_BatchArchetype},
    ::Val{CT},
) where {W<:World,CT<:Tuple}
    comp_types = CT.parameters
    world_storage_modes = W.parameters[3].parameters

    # TODO: keeping this for now to make iteration consistent with queries
    storage_modes = [
        world_storage_modes[Int(_component_id(W.parameters[1], T))]
        for T in comp_types
    ]
    comp_tuple_type = Expr(:curly, :Tuple, comp_types...)
    storage_tuple_mode = Expr(:curly, :Tuple, storage_modes...)

    return quote
        Batch{$W,$comp_tuple_type,$storage_tuple_mode,$(length(comp_types))}(
            world,
            archetypes,
            _get_entity(world._handles),
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
    if !_is_alive(b._world._handles, b._handle)
        throw(InvalidStateException("batch closed, batches can't be used multiple times", :batch_closed))
    end
    _recycle(b._world._handles, b._handle)
    return Base.iterate(b, 1)
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
    _unlock(b._world._lock, b._lock)
end

@generated function _get_columns_at_index(b::Batch{W,TS,SM,N}, idx::Int) where {W<:World,TS<:Tuple,SM<:Tuple,N}
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

        if isbitstype(comp_types[i]) && storage_modes[i] == VectorStorage
            push!(exprs, :($vec_sym = _new_fields_view(view($col_sym, arch.start_idx:arch.end_idx))))
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
