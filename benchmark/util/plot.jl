using DataFrames
using CSV
using Plots

function plot_aos(in_file::String, out_file::String; dark::Bool=false)
    df_raw = CSV.read(in_file, DataFrame)
    df = unstack(df_raw, [:Bytes, :Vars, :N], :Name, :Time)

    default(background_color=:transparent)
    if dark
        default(foreground_color=:white)
    else
        default(foreground_color=:black)
    end

    plt = plot(xscale=:log10, xlabel="Number of entities", ylabel="Time per entity [ns]", title="Benchmark vs. Array of Structs")

    sizes = unique(select(df, [:Bytes, :Vars]))

    for (impl, color, label) in [(Symbol("benchmark_ark"), :blue, "Ark"), (Symbol("benchmark_outer"), :red, "AoS")]
        for row in eachrow(sizes)
            bytes = row.Bytes
            vars = row.Vars
            subset = filter(r -> r.Bytes == bytes && r.Vars == vars, df)
            label_ark = "$label ($(bytes)B / $(vars) Vars)"
            plot!(subset.N, subset[!, impl], label=label_ark, lw=0.3 + 0.5 * log2(vars), color=color)
        end
    end

    savefig(out_file)
end
