
using Ark
using BenchmarkTools
using Chairmarks

const SECONDS = 0.5
const SUITE = BenchmarkGroup()

include("BenchTypes.jl")

include("bench_ark.jl")
include("bench_aos_outer_2.jl")
include("bench_aos_outer_4.jl")
include("bench_aos_outer_8.jl")
