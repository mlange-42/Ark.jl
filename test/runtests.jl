
ENV["ARK_RUNNING_TESTS"] = true

using Ark
using Ark: _find_or_create_archetype!, _create_entity!, _move_entity!, _get_storage, _component_id
using Ark: _new_entity, _EntityIndex, _ComponentStorage
using Ark: _new_entities_column
using Ark: _Archetype, _add_entity!
using Ark: _ComponentRegistry, _get_id!, _register_component!
using Ark: _Mask, _MaskNot
using Ark: _get_bit, _contains_all, _contains_any, _and, _or, _clear_bits, _active_bit_indices
using Ark: _is_zero, _is_not_zero
using Ark: _MutableMask, _get_bit, _set_bit!, _clear_bit!
using Ark: _EntityPool, _get_entity, _recycle, _is_alive
using Ark: _BitPool, _get_bit
using Ark: _Lock, _lock, _unlock, _is_locked
using Ark: _ComponentStorage
using Ark: _VecMap, _get_map, _set_map!
using Ark: _Graph, _GraphNode, _find_node, _find_or_create
using Ark: _BatchArchetype, _QueryLock
using Ark: _has_observers
using Ark: _StructArray, _StructArray_type, StructArrayView
using Ark: FieldsView, FieldView, _new_fields_view, _new_field_subarray

using Test

include("TestTypes.jl")

include("test_subarray.jl")
include("test_structarray.jl")
include("test_readme.jl")
include("test_entity.jl")
include("test_pool.jl")
include("test_lock.jl")
include("test_mask.jl")
include("test_event.jl")
include("test_query.jl")
include("test_batch.jl")
include("test_registry.jl")
include("test_vec_map.jl")
include("test_graph.jl")
include("test_world.jl")
include("test_quality.jl")

ENV["ARK_RUNNING_TESTS"] = false
