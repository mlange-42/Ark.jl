
include("util/process.jl")
include("util/compare.jl")
include("util/plot.jl")
include("array_of_structs/benchmarks.jl")

result = process_benches_aos(SUITE)
write_bench_table_aos(result, "bench_aos.csv")

for r in result
    @printf("%-20s  %3dB  %7d  %6.2fns\n", r.name, r.bytes, r.n, r.time_ns)
end

plot_aos("bench_aos.csv", "bench_aos_light.svg")
plot_aos("bench_aos.csv", "bench_aos_dark.svg"; dark=true)
