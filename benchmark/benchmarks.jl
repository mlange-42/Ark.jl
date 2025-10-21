
using Ark

using ChairmarksForAirspeedVelocity

include("BenchTypes.jl")

const SUITE = BenchmarkGroup()

include("bench_query_posvel.jl")
include("bench_map_posvel.jl")
include("bench_map_get_1.jl")
include("bench_map_get_5.jl")
include("bench_new_entity_1.jl")
include("bench_new_entity_5.jl")
include("bench_add_remove.jl")
