
function setup_flat_32B(n_entities::Int)
    vec = Vector{AosFlat_32B}()
    for _ in 1:n_entities
        push!(vec, AosFlat_32B())
    end
    return vec
end

function benchmark_flat_32B(args, n)
    vec = args
    @inbounds for entity in vec
        entity.x += entity.dx
        entity.y += entity.dy
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_flat bytes=032 n=$n"] = @be setup_flat_32B($n) benchmark_flat_32B(_, $n) seconds = SECONDS
end

function setup_flat_64B(n_entities::Int)
    vec = Vector{AosFlat_64B}()
    for _ in 1:n_entities
        push!(vec, AosFlat_64B())
    end
    return vec
end

function benchmark_flat_64B(args, n)
    vec = args
    @inbounds for entity in vec
        entity.x += entity.dx
        entity.y += entity.dy
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_flat bytes=064 n=$n"] = @be setup_flat_64B($n) benchmark_flat_64B(_, $n) seconds = SECONDS
end

function setup_flat_128B(n_entities::Int)
    vec = Vector{AosFlat_128B}()
    for _ in 1:n_entities
        push!(vec, AosFlat_128B())
    end
    return vec
end

function benchmark_flat_128B(args, n)
    vec = args
    @inbounds for entity in vec
        entity.x += entity.dx
        entity.y += entity.dy
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_flat bytes=128 n=$n"] = @be setup_flat_128B($n) benchmark_flat_128B(_, $n) seconds = SECONDS
end
