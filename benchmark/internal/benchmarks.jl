using Ark
using BenchmarkTools
using Chairmarks

const SECONDS = 0.5
const SUITE = BenchmarkGroup()

include("bench_callback.jl")
include("bench_mask_contains_all.jl")
include("bench_mask_contains_any.jl")
include("bench_set_mask.jl")
include("bench_lock_unlock.jl")
