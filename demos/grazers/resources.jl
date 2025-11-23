struct GrassGrid
    grass::Observable{Array{Float64,2}}
end

struct WorldSize
    width::Int
    height::Int
    scale::Int
end

struct Window
    scene::GLMakie.Scene
    screen::GLMakie.Screen
end

struct Grazers
    positions::Observable{Vector{Point2f}}
    rotations::Observable{Vector{Float64}}
end
