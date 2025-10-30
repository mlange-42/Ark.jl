
function setup_outer_4(n_entities::Int)
    vec = Vector{AosOuter4}()
    for _ in 1:n_entities
        push!(vec, AosOuter4())
    end
    return vec
end

function benchmark_outer_4(args, n)
    vec = args
    @inbounds for entity in vec
        pos = entity.pos
        vel = entity.vel
        entity.pos = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_outer_4 n=$n"] = @be setup_outer_4($n) benchmark_outer_4(_, $n) seconds = SECONDS
end
