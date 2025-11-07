
include("util/process.jl")
include("util/compare.jl")
include("benches/benchmarks.jl")

result = process_benches(SUITE)
write_bench_table(result, "bench.csv")

for r in result
    @printf("%-40s %7d  %6.2fns\n", r.name, r.n, r.time_ns)
end
