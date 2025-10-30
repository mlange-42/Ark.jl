
function setup_outer_32B(n_entities::Int)
    vec = Vector{AosOuter_32B}()
    for _ in 1:n_entities
        push!(vec, AosOuter_32B())
    end
    return vec
end

function benchmark_outer_32B(args, n)
    vec = args
    @inbounds for entity in vec
        pos = entity.pos
        vel = entity.vel
        entity.pos = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_outer bytes=032 n=$n"] = @be setup_outer_32B($n) benchmark_outer_32B(_, $n) seconds = SECONDS
end

function setup_outer_64B(n_entities::Int)
    vec = Vector{AosOuter_64B}()
    for _ in 1:n_entities
        push!(vec, AosOuter_64B())
    end
    return vec
end

function benchmark_outer_64B(args, n)
    vec = args
    @inbounds for entity in vec
        pos = entity.pos
        vel = entity.vel
        entity.pos = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_outer bytes=064 n=$n"] = @be setup_outer_64B($n) benchmark_outer_64B(_, $n) seconds = SECONDS
end

function setup_outer_128B(n_entities::Int)
    vec = Vector{AosOuter_128B}()
    for _ in 1:n_entities
        push!(vec, AosOuter_128B())
    end
    return vec
end

function benchmark_outer_128B(args, n)
    vec = args
    @inbounds for entity in vec
        pos = entity.pos
        vel = entity.vel
        entity.pos = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_outer bytes=128 n=$n"] = @be setup_outer_128B($n) benchmark_outer_128B(_, $n) seconds = SECONDS
end
