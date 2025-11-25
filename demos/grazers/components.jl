
const Position = Point2f
const Rotation = Float64

struct Energy
    value::Float64
end

struct Moving end
struct Grazing end

struct Genes
    max_angle::Float64
    reverse_prob::Float64
    move_thresh::Float64
    graze_thresh::Float64
    num_offspring::Float64
    energy_share::Float64
end

Genes(;
    max_angle::Float64,
    reverse_prob::Float64,
    move_thresh::Float64,
    graze_thresh::Float64,
    num_offspring::Float64,
    energy_share::Float64,
) = Genes(max_angle, reverse_prob, move_thresh, graze_thresh, num_offspring, energy_share)
