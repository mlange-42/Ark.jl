
include("util.jl")
include("benchmarks.jl")

function process_benches(suite::BenchmarkGroup)::Vector{Row}
    data = Vector{Row}()
    sorted_keys = sort(collect(keys(suite)))

    for name in sorted_keys
        bench = suite[name]
        parts = split(name, " n=")
        n = parse(Int, parts[end])
        mean_secs = median(map(s -> s.time, bench.samples))
        ns_per_n = 1e9 * mean_secs / n
        push!(data, Row(parts[1], n, ns_per_n))
    end

    return data
end

result = process_benches(SUITE)
write_bench_table(result, "bench.csv")

for r in result
    @printf("%-30s %7d  %6.2fns\n", r.name, r.n, r.time_ns)
end
