module Ark

using StaticArrays

include("util.jl")
include("entity.jl")
include("mask.jl")
include("vec_map.jl")
include("storage.jl")
include("graph.jl")
include("archetype.jl")
include("registry.jl")
include("pool.jl")
include("lock.jl")
include("world.jl")
include("map.jl")
include("query.jl")

export World
export is_alive, new_entity!, remove_entity!, zero_entity, is_locked
export _find_or_create_archetype!, _create_entity!, _move_entity!, _get_storage, _get_storage_by_id, _component_id

export Entity
export is_zero, _new_entity, _EntityIndex, _ComponentStorage

export Map
export new_entity!, get_components, set_components!, has_components, add_components!, remove_components!

export Query
export entities, close

export Column
export _new_column

export _Archetype
export _add_entity!

export _ComponentRegistry
export _component_id!, _get_id!

export _Mask
export _get_bit, _contains_all, _contains_any, _and, _or, _clear_bits, _active_bit_indices

export _MutableMask
export _get_bit, _set_bit!, _clear_bit!

export _EntityPool
export _get_entity, _recycle, _is_alive

export _BitPool
export _get_bit

export _Lock
export _lock, _unlock, _is_locked

export _ComponentStorage

export _VecMap
export _get_map, _set_map!

export _Graph, _GraphNode
export _find_node, _find_or_create

end
