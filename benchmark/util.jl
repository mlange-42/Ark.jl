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

function trim_prefix(s::String, prefix::String)
    startswith(s, prefix) ? s[length(prefix)+1:end] : s
end

function write_bench_table(data::Vector{Row}, file::String)
    open(file, "w") do io
        write(io, "Name,N,Time\n")
        for row in data
            write(io, "$(row.name),$(row.n),$(row.time_ns)\n")
        end
    end
end

function table_to_csv(data::Vector{CompareRow})::String
    header = "Name,N,Time main,Time curr,Factor"
    body = join([
            "$(row.name),$(row.n),$(row.time_ns_a),$(row.time_ns_b),$(row.factor)"
            for row in data
        ], "\n")
    return header * body
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

function table_to_html(data::Vector{CompareRow})::String
    html = """
    <details>
    <summary>Click to expand benchmark results</summary>
    <table>
      <thead>
        <tr>
          <th align="center">N</th>
          <th align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Time main&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
          <th align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Time curr&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
          <th align="center">&nbsp;&nbsp;&nbsp;&nbsp;Factor&nbsp;&nbsp;&nbsp;&nbsp;</th>
        </tr>
      </thead>
      <tbody>
    """

    improved = false
    regressed = false

    name = ""
    for r in data
        emoji = ""
        if r.factor <= 0.9
            improved = true
            emoji = "🚀"
        elseif r.factor >= 1.1
            regressed = true
            emoji = "⚠️"
        end

        if name != r.name
            name_short = trim_prefix(r.name, "benchmark_")
            html *= @sprintf("""<tr><th colspan="4" align="center">%s</th></tr>\n""", name_short)
        end

        html *= @sprintf("""
            <tr>
            <td align="right">%d</td>
            <td align="right">%.2fns</td>
            <td align="right">%.2fns</td>
            <td align="right">%s %.2f</td>
            </tr>
            """, r.n, r.time_ns_a, r.time_ns_b, emoji, r.factor)

        name = r.name
    end

    html *= """
      </tbody>
    </table>
    </details>
    """

    text = if regressed
        "<p>⚠️ Benchmark regression detected!</p>"
    elseif improved
        "<p>🚀 Benchmark improvement detected!</p>"
    else
        "<p>✅ Benchmarks are stable!</p>"
    end
    html = text * "\n" * html

    return html
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

function compare_multi_tables(a::Vector{Vector{Row}}, b::Vector{Vector{Row}})::Vector{CompareRow}
    compare_multi = [compare_tables(a, b) for (a, b) in zip(a, b)]

    count = length(compare_multi)
    data = Vector{CompareRow}
    for r in eachindex(compare_multi[1])
        out::CompareRow = CompareRow()
        for t in compare_multi
            row = t[r]
            out.name = row.name
            out.n = row.n
            out.time_ns_a += row.time_ns_a
            out.time_ns_b += row.time_ns_b
            out.factor += row.factor
        end
        out.time_ns_a /= count
        out.time_ns_b /= count
        out.factor /= count
        push!(data, out)
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
