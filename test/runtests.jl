
ENV["ARK_RUNNING_TESTS"] = true

using Test

const N_fake = 0
const offset_ID = 0

include("include_internals.jl")
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
