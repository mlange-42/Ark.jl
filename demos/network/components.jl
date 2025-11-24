
Position = Point2f

struct Node
    edges::Vector{Entity}
end

struct Edge
    node_a::Entity
    node_b::Entity
end

struct EdgePosition
    node_a::Point2f
    node_b::Point2f
end

struct EdgeLength
    length::Float64
end
