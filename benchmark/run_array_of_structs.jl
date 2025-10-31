
include("util/process.jl")
include("util/compare.jl")
include("array_of_structs/benchmarks.jl")

result = process_benches_aos(SUITE)
write_bench_table_aos(result, "bench.csv")

for r in result
    @printf("%-20s  %3dB  %7d  %6.2fns\n", r.name, r.bytes, r.n, r.time_ns)
end
