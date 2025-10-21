using BenchmarkTools
using Ark
using Printf

const full_output = !("--short" in ARGS)

include("BenchTypes.jl")
include("bench_query_posvel.jl")
include("bench_map_posvel.jl")
include("bench_map_get1.jl")
include("bench_map_get5.jl")
