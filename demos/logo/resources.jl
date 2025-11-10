struct WorldSize
    width::Int
    height::Int
end

function contains(s::WorldSize, x::Float64, y::Float64)
    return x >= 0.5 && y >= 0.5 && x <= s.width && y <= s.height
end

struct WorldScreen
    screen::GLMakie.Screen
end

struct WorldScene
    scene::GLMakie.Scene
end

mutable struct Mouse
    x::Float64
    y::Float64
    inside::Bool
end

struct Logo
    image::Array{RGBA{N0f8},2}
end
