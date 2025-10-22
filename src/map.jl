
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
    Map(world::World, comp_types::Tuple)

Creates a component mapper from a tuple of component types.
"""
Map(world::W, comp_types::Tuple) where {W<:World} = Map(world, comp_types...)

"""
    Map(world::World, comp_types::Type...)

Creates a component mapper from component types varargs.
"""
Map(world::W, comp_types::Type...) where {W<:World} = _Map_from_types(world, Val{Tuple{comp_types...}}())

@generated function _Map_from_types(world::W, ::Val{CT}) where {W<:World,CT<:Tuple}
    types = CT.parameters

    id_exprs = Expr[:(_component_id(world, $(QuoteNode(T)))) for T in types]
    ids_tuple = Expr(:tuple, id_exprs...)

    storage_exprs = Expr[:(_get_storage(world, $(QuoteNode(T)))) for T in types]
    storages_tuple = Expr(:tuple, storage_exprs...)

    storage_types = [:(_ComponentStorage{$(QuoteNode(T))}) for T in types]
    storage_tuple_type = :(Tuple{$(storage_types...)})

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
    Base.getindex(map::Map{W,CS,N}, entity::Entity) where {W<:World,CS<:Tuple,N}

Get components of an [`Entity`](@ref).
"""
@inline function Base.getindex(map::Map{W,CS,N}, entity::Entity) where {W<:World,CS<:Tuple,N}
    if !is_alive(map._world, entity)
        error("can't get components of a dead entity")
    end
    # TODO: currently raises MethodError of components are missing.
    # Should we pay the cost for a more informative error,
    # or for returning nothing?
    index = map._world._entities[entity._id]
    return @inline _get_mapped_components(map, index)
end

"""
    Base.setindex!(map::Map{W,CS,N}, value, entity::Entity) where {W<:World,CS<:Tuple,N}

Set components of an [`Entity`](@ref).
"""
@inline function Base.setindex!(map::Map{W,CS,N}, value, entity::Entity) where {W<:World,CS<:Tuple,N}
    if !is_alive(map._world, entity)
        error("can't set components of a dead entity")
    end
    index = map._world._entities[entity._id]
    @inline _set_entity_values!(map, index.archetype, index.row, value)
end

"""
    has_components(map::Map, entity::Entity)

Returns whether an [`Entity`](@ref) has the given components.
"""
@inline function has_components(map::Map{W,CS,N}, entity::Entity) where {W<:World,CS<:Tuple,N}
    if !is_alive(map._world, entity)
        error("can't check components of a dead entity")
    end
    index = map._world._entities[entity._id]
    return @inline _has_entity_components(map, index)
end

"""
    add_components!(map::Map{CS,1}, entity::Entity, value)::Entity

Adds 1 components to an [`Entity`](@ref).
"""
function add_components!(map::Map{W,CS}, entity::Entity, value) where {W<:World,CS<:Tuple}
    if !is_alive(map._world, entity)
        error("can't add components to a dead entity")
    end
    archetype = _find_or_create_archetype!(map._world, entity, map._ids, ())
    row = _move_entity!(map._world, entity, archetype)
    _set_entity_values!(map, archetype, row, value)
end

"""
    remove_components!(map::Map{CS,1}, entity::Entity)

Removes 1 components from an [`Entity`](@ref).
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
        stor = Symbol("stor", i)
        col = Symbol("col", i)
        val = Symbol("v", i)
        push!(exprs, :($stor = map._storage[$i]))
        push!(exprs, :($col = $stor.data[index.archetype]))
        push!(exprs, :($val = $col._data[index.row]))
    end
    vals = [Symbol("v", i) for i in 1:N]
    push!(exprs, Expr(:return, Expr(:tuple, vals...)))
    return quote
        @inbounds begin
            $(Expr(:block, exprs...))
        end
    end
end

@generated function _set_entity_values!(map::Map{W,CS,N}, archetype::UInt32, row::UInt32, comps) where {W<:World,CS<:Tuple,N}
    exprs = Expr[]
    for i in 1:N
        stor = Symbol("stor", i)
        col = Symbol("col", i)
        push!(exprs, :($stor = map._storage[$i]))
        push!(exprs, :($col = $stor.data[archetype]))
        push!(exprs, :($col._data[row] = comps[$i]))
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
        stor = Symbol("stor", i)
        col = Symbol("col", i)
        push!(exprs, :($stor = map._storage[$i]))
        push!(exprs, :($col = $stor.data[index.archetype]))
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

