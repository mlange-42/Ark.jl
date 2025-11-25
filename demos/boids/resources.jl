struct WorldSize
    width::Int
    height::Int
end

struct Window
    screen::GLMakie.Screen
end

struct PlotData
    positions::Observable{Vector{Position}}
    rotations::Observable{Vector{Rotation}}
end

PlotData() = PlotData(
    Observable(Vector{Position}()),
    Observable(Vector{Rotation}()),
)
