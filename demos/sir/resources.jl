
struct Buffer
    i_to_r::Vector{Entity}
    s_to_i::Vector{Entity}
    rands::Vector{Float64}
    ents::Vector{Entity}
    function Buffer(i_to_r, s_to_i, rands, ents)
        # hint to max capacity for more fluid simulations
        sizehint!(i_to_r, 10^7)
        sizehint!(s_to_i, 10^7)
        sizehint!(rands, 10^7)
        sizehint!(ents, 10^7)
        return new(i_to_r, s_to_i, rands, ents)
    end
end

mutable struct Params
    N::Int
    I0::Int
    beta::Float64
    c::Float64
    r::Float64
    dt::Float64
end
