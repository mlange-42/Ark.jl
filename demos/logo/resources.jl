struct WorldSize
    width::Int
    height::Int
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
