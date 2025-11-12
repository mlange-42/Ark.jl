
include("util/process.jl")
include("util/compare.jl")
include("internal/benchmarks.jl")

result = process_benches(SUITE)
write_bench_table(result, "bench.csv")

for r in result
    @printf("%-40s %7d  %6.2fns, %7d allocs, %7dB\n", r.name, r.n, r.time_ns, r.allocs, r.bytes)
end
