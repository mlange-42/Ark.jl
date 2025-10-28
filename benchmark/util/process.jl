
using BenchmarkTools

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
