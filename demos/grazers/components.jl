
const Position = Point2f
const Rotation = Float64

struct Moving end
struct Grazing end

struct Genes
    max_angle::Float64
end

Genes(;
    max_angle::Float64,
) = Genes(max_angle)
