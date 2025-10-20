module Ark

include("util.jl")
include("entity.jl")
include("mask.jl")
include("storage.jl")
include("archetype.jl")
include("registry.jl")
include("world.jl")
include("map.jl")
include("query.jl")

export World
export is_alive, new_entity!, remove_entity!, zero_entity
export _find_or_create_archetype!, _create_entity!, _get_storage

export Entity
export is_zero, _new_entity, _EntityIndex, _ComponentStorage

export Map2
export new_entity!, get_components, set_components!, has_components, add_components!, remove_components!

export Query2

export Column
export _new_column

export _Archetype
export _add_entity!

export _ComponentRegistry
export _component_id!

export _Mask
export _get_bit, _contains_all, _contains_any, _and, _or, _active_bit_indices

export _MutableMask
export _get_bit, _set_bit!, _clear_bit!

export _EntityPool
export _get_entity, _recycle, _is_alive

export _ComponentStorage

end