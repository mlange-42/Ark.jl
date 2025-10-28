
using Ark
using Ark: _find_or_create_archetype!, _create_entity!, _move_entity!, _get_storage, _get_storage_by_id, _component_id
using Ark: _new_entity, _EntityIndex, _ComponentStorage
using Ark: _get_mapped_components
using Ark: _new_column, _new_entities_column
using Ark: _Archetype, _add_entity!
using Ark: _ComponentRegistry, _get_id!, _register_component!
using Ark: _Mask, _get_bit, _contains_all, _contains_any, _and, _or, _clear_bits, _active_bit_indices
using Ark: _MutableMask, _get_bit, _set_bit!, _clear_bit!
using Ark: _EntityPool, _get_entity, _recycle, _is_alive
using Ark: _BitPool, _get_bit
using Ark: _Lock, _lock, _unlock, _is_locked
using Ark: _ComponentStorage
using Ark: _VecMap, _get_map, _set_map!
using Ark: _Graph, _GraphNode, _find_node, _find_or_create
using Ark: _BatchArchetype

using Test

include("TestTypes.jl")

include("test_readme.jl")
include("test_entity.jl")
include("test_pool.jl")
include("test_lock.jl")
include("test_mask.jl")
include("test_map.jl")
include("test_query.jl")
include("test_batch.jl")
include("test_registry.jl")
include("test_column.jl")
include("test_vec_map.jl")
include("test_graph.jl")
include("test_world.jl")
include("test_quality.jl")
