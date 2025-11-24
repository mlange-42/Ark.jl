
struct WorldSize
    width::Int
    height::Int
end

struct Window
    screen::GLMakie.Screen
end

struct PlotData
    nodes::Observable{Vector{Position}}
end

PlotData() = PlotData(Observable(Vector{Position}()))
