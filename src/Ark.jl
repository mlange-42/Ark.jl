module Ark

include("entity.jl")
include("mask.jl")
include("archetype.jl")
include("registry.jl")
include("storage.jl")
include("world.jl")

export World, Entity
export _Archetype

export _ComponentRegistry
export _component_id!

export _Mask
export _get_bit, _contains_all, _contains_any

export _EntityPool
export _get_entity, _recycle, _alive

end