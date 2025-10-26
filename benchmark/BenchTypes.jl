
struct Position
    x::Float64
    y::Float64
end

struct Velocity
    dx::Float64
    dy::Float64
end

struct CompA
    x::Float64
    y::Float64
end

struct CompB
    x::Float64
    y::Float64
end

struct CompC
    x::Float64
    y::Float64
end

struct CompN{N} end

mutable struct Tick
    time::Int
end