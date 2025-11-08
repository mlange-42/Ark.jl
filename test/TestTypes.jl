
struct Position
    x::Float64
    y::Float64
end

struct Velocity
    dx::Float64
    dy::Float64
end

struct Altitude
    alt::Float64
end

struct Health
    health::Float64
end

struct Dummy end

struct LabelComponent end

struct CompN{N} end

mutable struct MutableComponent
    dummy::Int64
end

struct NoIsBits
    v::Vector{Int}
end

mutable struct Tick
    time::Int
end
