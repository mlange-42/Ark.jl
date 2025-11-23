
struct Buffer
    i_to_r::Vector{Entity}
    s_to_i::Vector{Entity}
    rands::Vector{Float64}
    ents::Vector{Entity}
end

mutable struct Params
    N::Int
    I0::Int
    beta::Float64
    c::Float64
    r::Float64
    dt::Float64
end
