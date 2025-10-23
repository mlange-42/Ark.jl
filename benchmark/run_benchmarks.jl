using Printf

include("benchmarks.jl")

sorted_keys = sort(collect(keys(SUITE)))

for name in sorted_keys
    bench = SUITE[name]
    n = parse(Int, split(name, "n=")[end])
    mean_secs = median(map(s -> s.time, bench.samples))
    ns_per_n = 1e9 * mean_secs / n
    @printf("%-50s %6.2fns\n", name, ns_per_n)
end
