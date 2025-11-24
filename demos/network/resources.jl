
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
end

PlotData() = PlotData(Observable(Vector{Position}()), Observable(Vector{Tuple{Position,Position}}()))
