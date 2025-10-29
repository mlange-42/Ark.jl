
"""
    Map

A component mapper for N components.
"""
struct Map{W<:World,CT<:Tuple}
    _world::W
    _types::CT
    _dummy::Bool # TODO: Get rid of this without method overwriting error!
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

@generated function _Map_from_types(world::W, comp_types::CT) where {W<:World,CT<:Tuple}
    types = [x.parameters[1] for x in CT.parameters]

    # Just to check that all components are present in the world.
    id_exprs = Expr[:(_component_id(world, $(QuoteNode(T)))) for T in types]
    ids_tuple = Expr(:tuple, id_exprs...)

    return quote
        $ids_tuple
        Map{$W,$CT}(world, comp_types, false)
    end
end

"""
    Base.getindex(map::Map, entity::Entity)

Get the Map's components for an [`Entity`](@ref).
"""
@inline function Base.getindex(map::Map{W,CT}, entity::Entity) where {W<:World,CT<:Tuple}
    world = map._world
    if !is_alive(world, entity)
        error("can't get components of a dead entity")
    end
    return @inline _get_components(world, entity, map._types)
end

"""
    Base.setindex!(map::Map, values::Tuple, entity::Entity)

Sets the given components values for an [`Entity`](@ref).
Types are inferred from the values and don't need to match the map's component types.
The entity must already have all these components.
"""
@inline function Base.setindex!(map::Map{W,CT}, values::Tuple, entity::Entity) where {W<:World,CT<:Tuple}
    @inline set_components!(map._world, entity, values)
end

"""
    has_components(map::Map, entity::Entity)

Returns whether an [`Entity`](@ref) has all the Map's components.
"""
@inline function has_components(map::Map{W,CT}, entity::Entity) where {W<:World,CT<:Tuple}
    world = map._world
    if !is_alive(world, entity)
        error("can't check components of a dead entity")
    end
    index = world._entities[entity._id]
    return @inline _has_components(world, index, map._types)
end

"""
    add_components!(map::Map, entity::Entity, value::Tuple)

Adds the given components values to an [`Entity`](@ref).
Types are inferred from the values and don't need to match the map's component types.
"""
function add_components!(map::Map{W,CT}, entity::Entity, values::Tuple) where {W<:World,CT<:Tuple}
    @inline add_components!(map._world, entity, values)
end

"""
    remove_components!(map::Map, entity::Entity)

Removes the Map's components from an [`Entity`](@ref).
"""
function remove_components!(map::Map{W,CT}, entity::Entity) where {W<:World,CT<:Tuple}
    world = map._world
    if !is_alive(world, entity)
        error("can't remove components from a dead entity")
    end
    return _exchange_components!(world, entity, Val{Tuple{}}(), (), map._types)
end

"""
    new_entity!(map::Map, values::Tuple)::Entity

Creates a new [`Entity`](@ref) with the given components.
Types are inferred from the values and don't need to match the map's component types.
"""
function new_entity!(map::Map{W,CT}, values::Tuple) where {W<:World,CT<:Tuple}
    return new_entity!(map._world, values)
end
