using DataFrames
using CSV
using Plots
using Printf

function thousands(num::Integer)
    str = string(num)
    return replace(str, r"(?<=[0-9])(?=(?:[0-9]{3})+(?![0-9]))" => "'")
end

function plot_aos(in_file::String, out_file::String; dark::Bool=false)
    df_raw = CSV.read(in_file, DataFrame)
    df = unstack(df_raw, [:Bytes, :Vars, :N], :Name, :Time)

    family = "Courier"

    labels = [(Symbol("benchmark_ark"), "Ark"), (Symbol("benchmark_outer"), "AoS")]
    colors_dark = ["#1abc9c", "#fff"]
    colors_light = ["#2e63b8", "#000"]
    colors = []

    default(background_color=:transparent)
    default(fontfamily=family)
    if dark
        colors = colors_dark
        default(foreground_color=:white)
        default(legendfont=font(family, 10, color=:white))
        default(xtickfont=font(family, 10, color=:white))
        default(ytickfont=font(family, 10, color=:white))
    else
        colors = colors_light
        default(foreground_color=:black)
        default(legendfont=font(family, 10, color=:black))
        default(xtickfont=font(family, 10, color=:black))
        default(ytickfont=font(family, 10, color=:black))
    end

    xvals = [100, 1_000, 10_000, 100_000, 1_000_000]
    xtick_labels = map(x -> thousands(x), xvals)
    plt = plot(xscale=:log10,
        title="Benchmark vs. Array of Structs",
        xlabel="Number of entities",
        ylabel="Time per entity [ns]",
        size=(640, 400),
        xlim=(80, 2.5e6),
        ylim=(0, NaN),
        xticks=(xvals, xtick_labels),
        legend=:topleft,
    )

    sizes = unique(select(df, [:Bytes, :Vars]))

    for ((impl, label), color) in zip(labels, colors)
        for row in eachrow(sizes)
            bytes = row.Bytes
            vars = row.Vars
            subset = filter(r -> r.Bytes == bytes && r.Vars == vars, df)
            label_ark = @sprintf "%s (%3dB,\u2003%2d Vars)" label bytes vars
            plot!(subset.N, subset[!, impl], label=label_ark,
                lw=0.3 + 0.5 * log2(vars),
                color=color)
        end
    end

    savefig(out_file)
end
