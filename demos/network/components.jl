
struct Position
    x::Float64
    y::Float64
end

struct Node
    edges::Vector{Entity}
end

struct Edge
    node_a::Entity
    node_b::Entity
end
