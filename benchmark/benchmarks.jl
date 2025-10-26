
using Ark
using BenchmarkTools
using Chairmarks

const SECONDS = 0.5
const SUITE = BenchmarkGroup()

include("BenchTypes.jl")

include("bench_query_create.jl")
include("bench_query_posvel.jl")
include("bench_world_posvel.jl")
include("bench_world_get_1.jl")
include("bench_world_get_5.jl")
include("bench_world_new_entity_1.jl")
include("bench_world_new_entity_5.jl")
include("bench_world_add_remove.jl")
include("bench_map_posvel.jl")
include("bench_map_get_1.jl")
include("bench_map_get_5.jl")
include("bench_map_new_entity_1.jl")
include("bench_map_new_entity_5.jl")
include("bench_map_add_remove.jl")
include("bench_resource.jl")