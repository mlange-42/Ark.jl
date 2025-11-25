struct WorldSize
    width::Int
    height::Int
end

function contains(s::WorldSize, x::Float64, y::Float64)
    return x >= 0 && y >= 0 && x <= s.width && y <= s.height
end

struct Window
    screen::GLMakie.Screen
    scene::GLMakie.Scene
end

mutable struct Mouse
    x::Float64
    y::Float64
    inside::Bool
end

struct PlotData
    positions::Observable{Vector{Point2f}}
    rotations::Observable{Vector{Float64}}
end

PlotData() = PlotData(
    Observable(Vector{Point2f}()),
    Observable(Vector{Float64}()),
)

struct Grid
    entities::Array{Vector{Entity},2}
    rows::Int
    cols::Int
    cell_size::Int
end

function Grid(width::Int, height::Int, max_dist::Int)
    rows = ceil(Int, height / max_dist)
    cols = ceil(Int, width / max_dist)

    g = Array{Vector{Entity}}(undef, rows, cols)
    for i in 1:rows, j in 1:cols
        g[i, j] = Entity[]
    end

    return Grid(g, rows, cols, max_dist)
end

function cell(g::Grid, p::Point2f)
    row = floor(Int, p[2] / g.cell_size) + 1
    col = floor(Int, p[1] / g.cell_size) + 1

    return clamp(row, 1, g.rows), clamp(col, 1, g.cols)
end
