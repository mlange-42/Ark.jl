using BenchmarkTools
using Printf

struct Row
    name::String
    n::Int
    time_ns::Float64
end

mutable struct CompareRow
    name::String
    n::Int
    time_ns_a::Float64
    time_ns_b::Float64
    factor::Float64
end

function CompareRow()
    CompareRow("", 0, NaN, NaN, NaN)
end

function process_benches(suite::BenchmarkGroup)::Vector{Row}
    data = Vector{Row}()
    sorted_keys = sort(collect(keys(SUITE)))

    for name in sorted_keys
        bench = SUITE[name]
        parts = split(name, " n=")
        n = parse(Int, parts[end])
        mean_secs = median(map(s -> s.time, bench.samples))
        ns_per_n = 1e9 * mean_secs / n
        push!(data, Row(parts[1], n, ns_per_n))
    end

    return data
end

function write_bench_table(data::Vector{Row}, file::String)
    open(file, "w") do io
        write(io, "Name,N,Time\n")
        for row in data
            write(io, "$(row.name),$(row.n),$(row.time_ns)\n")
        end
    end
end

function write_compare_table(data::Vector{CompareRow}, file::String)
    open(file, "w") do io
        write(io, "Name,N,Time main,Time curr,Factor\n")
        for row in data
            write(io, "$(row.name),$(row.n),$(row.time_ns_a),$(row.time_ns_b),$(row.factor)\n")
        end
    end
end

function table_to_markdown(data::Vector{CompareRow})::String
    header = "| Name                           |       N | Time main [ns] | Time curr [ns] | Factor |\n" *
             "|:-------------------------------|--------:|---------------:|---------------:|-------:|\n"

    body = join([
            @sprintf("| %-30s | %7d | %14.2f | %14.2f | %6.2f |",
                r.name, r.n, r.time_ns_a, r.time_ns_b, r.factor)
            for r in data
        ], "\n")

    return header * body
end

function read_bench_table(file::String)::Vector{Row}
    data = Vector{Row}()
    open(file, "r") do io
        for line in Iterators.drop(eachline(io), 1)
            parts = split(line, ",")
            push!(data, Row(
                parts[1],
                parse(Int, parts[2]),
                parse(Float64, parts[3]),
            ))
        end
    end
    return data
end

function compare_tables(a::Vector{Row}, b::Vector{Row})::Vector{CompareRow}
    dict_a = Dict(@sprintf("%s %07d", x.name, x.n) => x for x in a)
    dict_b = Dict(@sprintf("%s %07d", x.name, x.n) => x for x in b)

    keys_set = Set{String}()

    for k in keys(dict_a)
        push!(keys_set, k)
    end
    for k in keys(dict_b)
        push!(keys_set, k)
    end
    keys_vec = sort(collect(keys_set))
    data = Vector{CompareRow}()

    for bench in keys_vec
        row = CompareRow()
        if haskey(dict_a, bench)
            r = dict_a[bench]
            row.name = r.name
            row.n = r.n
            row.time_ns_a = r.time_ns
        end
        if haskey(dict_b, bench)
            r = dict_b[bench]
            row.name = r.name
            row.n = r.n
            row.time_ns_b = r.time_ns
        end
        row.factor = row.time_ns_b / row.time_ns_a
        push!(data, row)
    end

    return data
end
