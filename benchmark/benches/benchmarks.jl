using Ark
using BenchmarkTools
using Chairmarks

const SECONDS = 0.5
const SUITE = BenchmarkGroup()

include("BenchTypes.jl")

include("bench_query_create.jl")
include("bench_query_posvel.jl")
include("bench_query_posvel_soa.jl")
include("bench_query_posvel_stored.jl")
include("bench_world_posvel.jl")
include("bench_world_get_1.jl")
include("bench_world_get_5.jl")
include("bench_world_set_1.jl")
include("bench_world_set_5.jl")
include("bench_world_update_1.jl")
include("bench_world_update_5.jl")
include("bench_world_new_entity_1.jl")
include("bench_world_new_entity_1_soa.jl")
include("bench_world_new_entity_5.jl")
include("bench_world_new_entity_5_soa.jl")
include("bench_world_new_entities_1_def.jl")
include("bench_world_new_entities_1.jl")
include("bench_world_new_entities_5_def.jl")
include("bench_world_new_entities_5.jl")
include("bench_world_add_remove_1.jl")
include("bench_world_add_remove_1_large.jl")
include("bench_world_add_remove_1_soa.jl")
include("bench_world_add_remove_8.jl")
include("bench_world_add_remove_8_large.jl")
include("bench_world_add_remove_8_soa.jl")
include("bench_resource.jl")
