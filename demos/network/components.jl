
Position = Point2f

struct Node
    edges::Vector{Entity}
end

struct Edge
    node_a::Entity
    node_b::Entity
end
