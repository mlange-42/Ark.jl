module Ark

# Useful to retrieve the README for the Ark docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) Ark

using StaticArrays

include("util.jl")
include("entity.jl")
include("mask.jl")
include("vec_map.jl")
include("column.jl")
include("storage.jl")
include("graph.jl")
include("archetype.jl")
include("index.jl")
include("registry.jl")
include("pool.jl")
include("lock.jl")
include("world.jl")
include("map.jl")
include("query.jl")
include("batch.jl")

include("docs.jl") # doctest setup

export World
export is_alive, new_entity!, new_entities!, @new_entities!, remove_entity!, zero_entity, is_locked
export get_components, @get_components, set_components!, has_components, @has_components
export add_components!, remove_components!, @remove_components!
export exchange_components!, @exchange_components!
export get_resource, has_resource, add_resource!, remove_resource!

export Entity
export is_zero

export Map, @Map

export Query, @Query, Batch
export close!

export Entities

end
