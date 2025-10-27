
"""
    Map{CS, N}

A component mapper for N components.
"""
struct Map{W<:World,CS<:Tuple,N}
    _world::W
    _ids::NTuple{N,UInt8}
    _storage::CS
end

"""
    @Map(world::World, comp_types::Tuple)

Macro version of [`Map`](@ref) for ergonomic construction of component mappers.

# Arguments
- `world`: The `World` instance to map components from.
- `comp_types::Tuple`: A tuple of component types, e.g. `(Position, Velocity)`.

# Example
```julia
@Map(world, (Position, Velocity))
```
"""
macro Map(world_expr, comp_types_expr)
    quote
        Map(
            $(esc(world_expr)),
            Val.($(esc(comp_types_expr)))
        )
    end
end

"""
    Map(world::World, comp_types::Tuple)

Creates a component mapper from a tuple of component types.

For a more convenient tuple syntax, the macro [`@Map`](@ref) is provided.

# Example
```julia
Map(world, Val.((Position, Velocity)))
```
"""
Map(world::W, comp_types::Tuple) where {W<:World} = _Map_from_types(world, comp_types)

@generated function _Map_from_types(world::W, ::CT) where {W<:World{CS},CT<:Tuple} where {CS<:Tuple}
    types = [x.parameters[1] for x in CT.parameters]

    id_exprs = [:(_component_id(world, $(QuoteNode(T)))) for T in types]
    ids_tuple = Expr(:tuple, id_exprs...)

    storage_exprs = Expr[]
    storage_types = Expr[]
    for T in types
        for (i, S) in enumerate(CS.parameters)
            if S <: _ComponentStorage && S.parameters[1] === T
                A = S.parameters[2]
                push!(storage_exprs, :(world._storages[$i]::$(QuoteNode(S))))
                push!(storage_types, Expr(:curly, :_ComponentStorage, QuoteNode(T), QuoteNode(A)))
                break
            end
        end
    end

    storages_tuple = Expr(:tuple, storage_exprs...)
    storage_tuple_type = Expr(:curly, :Tuple, storage_types...)

    return quote
        Map{$W,$storage_tuple_type,$(length(types))}(world, $ids_tuple, $storages_tuple)
    end
end

"""
    new_entity!(map::Map, comps::Tuple)::Entity

Creates a new [`Entity`](@ref) with `length(comps)` components.
"""
function new_entity!(map::Map{W,CS}, comps::Tuple) where {W<:World,CS<:Tuple}
    archetype =
        _find_or_create_archetype!(map._world, map._world._archetypes[1].node, map._ids, ())
    entity, index = _create_entity!(map._world, archetype)
    _set_entity_values!(map, archetype, index, comps)
    return entity
end

"""
    Base.getindex(map::Map, entity::Entity)

Get the Map's components for an [`Entity`](@ref).
"""
@inline function Base.getindex(map::Map{W,CS,N}, entity::Entity) where {W<:World,CS<:Tuple,N}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = @inbounds map._world._entities[Int(entity._id)]
    return @inline _get_mapped_components(map, index)
end

"""
    Base.setindex!(map::Map, values::Tuple, entity::Entity)

Sets the values of the Map's components for an [`Entity`](@ref).
The entity must already have all these components.
"""
@inline function Base.setindex!(map::Map{W,CS,N}, values::Tuple, entity::Entity) where {W<:World,CS<:Tuple,N}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = @inbounds map._world._entities[Int(entity._id)]
    @inline _set_entity_values!(map, index.archetype, index.row, values)
end

"""
    has_components(map::Map, entity::Entity)

Returns whether an [`Entity`](@ref) has all the Map's components.
"""
@inline function has_components(map::Map{W,CS,N}, entity::Entity) where {W<:World,CS<:Tuple,N}
    if !is_alive(map._world, entity)
        error("can't check components of a dead entity")
    end
    index = map._world._entities[Int(entity._id)]
    return @inline _has_entity_components(map, index)
end

"""
    add_components!(map::Map, entity::Entity, value::Tuple)

Adds the values of the Map's components to an [`Entity`](@ref).
"""
function add_components!(map::Map{W,CS}, entity::Entity, values::Tuple) where {W<:World,CS<:Tuple}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    _set_entity_values!(map, archetype, row, values)
end

"""
    remove_components!(map::Map, entity::Entity)

Removes the Map's components from an [`Entity`](@ref).
"""
function remove_components!(map::Map{W,CS}, entity::Entity) where {W<:World,CS<:Tuple}
    if !is_alive(map._world, entity)
        error("can't remove components from a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, (), map._ids)
    _move_entity!(map._world, entity, archetype)
end

@generated function _get_mapped_components(map::Map{W,CS,N}, index::_EntityIndex) where {W<:World,CS<:Tuple,N}
    exprs = Expr[]
    for i in 1:N
        S = CS.parameters[i]
        stor = Symbol("stor", i)
        col = Symbol("col", i)
        val = Symbol("v", i)
        push!(exprs, :($stor = map._storage.$i::$(QuoteNode(S))))
        push!(exprs, :(@inbounds $col = $stor.data[Int(index.archetype)]))
        push!(exprs, :(@inbounds $val = $col._data[Int(index.row)]))
    end
    vals = [Symbol("v", i) for i in 1:N]
    push!(exprs, Expr(:return, Expr(:tuple, vals...)))
    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

@generated function _set_entity_values!(map::Map{W,CS,N}, archetype::UInt32, row::UInt32, comps::Tuple) where {W<:World,CS<:Tuple,N}
    exprs = Expr[]
    for i in 1:N
        S = CS.parameters[i]
        C = S.parameters[1]
        stor = Symbol("stor", i)
        col = Symbol("col", i)
        val = Symbol("val", i)

        push!(exprs, :($stor = map._storage.$i::$(QuoteNode(S))))
        push!(exprs, :(@inbounds $col = $stor.data[Int(archetype)]))
        push!(exprs, :($val = (comps.$i)::$(QuoteNode(C))))
        push!(exprs, :(@inbounds $col._data[Int(row)] = $val))
    end
    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

@generated function _has_entity_components(map::Map{W,CS,N}, index::_EntityIndex) where {W<:World,CS<:Tuple,N}
    exprs = Expr[]
    for i in 1:N
        S = CS.parameters[i]
        stor = Symbol("stor", i)
        col = Symbol("col", i)
        push!(exprs, :($stor = map._storage.$i::$(QuoteNode(S))))
        push!(exprs, :(@inbounds $col = $stor.data[Int(index.archetype)]))
        push!(exprs, :(
            if $col === nothing
                return false
            end
        ))
    end
    push!(exprs, :(return true))
    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end
