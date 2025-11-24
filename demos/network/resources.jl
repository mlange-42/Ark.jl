
struct WorldSize
    width::Int
    height::Int
end

struct Window
    screen::GLMakie.Screen
end

struct PlotData
    nodes::Observable{Vector{Position}}
    edges::Observable{Vector{Tuple{Position,Position}}}
    travelers::Observable{Vector{Position}}
    colors::Observable{Vector{RGBf}}
end

PlotData() = PlotData(
    Observable(Vector{Position}()),
    Observable(Vector{Tuple{Position,Position}}()),
    Observable(Vector{Position}()),
    Observable(Vector{RGBf}()),
)
