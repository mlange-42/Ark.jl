
struct Position
    p::Point2f
end

struct Velocity
    v::Point2f
end

struct Rotation
    r::Float64
end

struct Neighbors
    n::Vector{Entity}
end

Neighbors() = Neighbors(Vector{Entity}())

struct UpdateStep
    step::Int
end
