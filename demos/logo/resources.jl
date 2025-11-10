struct WorldSize
    width::Int
    height::Int
end

function contains(s::WorldSize, x::Float64, y::Float64)
    return x >= 0 && y >= 0 && x <= s.width && y <= s.height
end

struct WorldScreen
    screen::GLMakie.Screen
end

struct WorldScene
    scene::GLMakie.Scene
end

mutable struct Mouse
    position::Tuple{Float64,Float64}
    inside::Bool
end
