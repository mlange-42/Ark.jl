module Ark

include("entity.jl")
include("mask.jl")
include("archetype.jl")
include("registry.jl")
include("storage.jl")
include("world.jl")
include("map.jl")

export World
export _find_or_create_archetype!, _create_entity!, _get_storage

export Entity
export _new_entity, _EntityIndex, _ComponentStorage

export Map2
export new_entity!, get_components

export _Archetype
export _add_entity!

export _ComponentRegistry
export _component_id!

export _Mask
export _get_bit, _contains_all, _contains_any

export _EntityPool
export _get_entity, _recycle, _alive

export _ComponentStorage

end