module Ark

using StaticArrays
using FunctionWrappers: FunctionWrapper

include("util.jl")
include("entity.jl")
include("mask.jl")
include("event.jl")
include("vec_map.jl")
include("storage.jl")
include("graph.jl")
include("archetype.jl")
include("index.jl")
include("registry.jl")
include("pool.jl")
include("lock.jl")
include("world.jl")
include("observer.jl")
include("query.jl")
include("batch.jl")

#include("docs.jl") # doctest setup

export World
export is_alive, new_entity!, new_entities!, @new_entities!, remove_entity!, zero_entity, is_locked
export get_components, @get_components, set_components!, has_components, @has_components
export add_components!, remove_components!, @remove_components!
export exchange_components!, @exchange_components!
export get_resource, has_resource, add_resource!, set_resource!, remove_resource!

export Entity
export is_zero

export Query, @Query, Batch
export close!

export Entities

export EventRegistry, new_event_type!
export OnCreateEntity, OnRemoveEntity

export Observer, @Observer

end
