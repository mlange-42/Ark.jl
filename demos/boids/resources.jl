struct WorldSize
    width::Int
    height::Int
end

struct Window
    screen::GLMakie.Screen
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
end
