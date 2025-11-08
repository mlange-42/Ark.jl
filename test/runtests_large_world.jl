
using Test

include("include_internals.jl")

function Ark.World(comp_types::Union{Type,Pair{<:Type,<:Type}}...; allow_mutable=false)
    types = map(arg -> arg isa Type ? arg : arg.first, comp_types)
    storages = map(arg -> arg isa Type ? VectorStorage : arg.second, comp_types)
    Ark._World_from_types(
        Val{Tuple{fake_types[1:63]...,types...,fake_types[64:100]...}}(),
        Val{Tuple{fake_storage[1:63]...,storages...,fake_storage[64:100]...}}(),
        Val(allow_mutable),
    )
end

struct FakeComp{N} end
const fake_types = [FakeComp{i} for i in 1:100]
const fake_storage = [VectorStorage for i in 1:100]
const N_fake = 100
const offset_ID = 63

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
