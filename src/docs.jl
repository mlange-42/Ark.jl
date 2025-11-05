# File to include as doctest setup:
# ```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl")))
# ...
# ```
struct Position
    x::Float64
    y::Float64
end

struct Velocity
    dx::Float64
    dy::Float64
end

struct PositionSoA <: StructArrayComponent
    x::Float64
    y::Float64
end

struct VelocitySoA <: StructArrayComponent
    dx::Float64
    dy::Float64
end

struct Altitude
    z::Float64
end

world = World(Position, Velocity, Altitude, PositionSoA, VelocitySoA)

entity = new_entity!(world, (Position(0, 0), Velocity(0, 0)))
