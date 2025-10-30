
function setup_immutable_32B(n_entities::Int)
    vec = Vector{AosImmutable_32B}()
    for _ in 1:n_entities
        push!(vec, AosImmutable_32B())
    end
    return vec
end

function benchmark_immutable_32B(args, n)
    vec = args
    @inbounds for (i, entity) in enumerate(vec)
        vec[i] = AosImmutable_32B(entity.x + entity.dx, entity.y + entity.dy)
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_immutable bytes=032 n=$n"] = @be setup_immutable_32B($n) benchmark_immutable_32B(_, $n) seconds = SECONDS
end

function setup_immutable_64B(n_entities::Int)
    vec = Vector{AosImmutable_64B}()
    for _ in 1:n_entities
        push!(vec, AosImmutable_64B())
    end
    return vec
end

function benchmark_immutable_64B(args, n)
    vec = args
    @inbounds for (i, entity) in enumerate(vec)
        vec[i] = AosImmutable_64B(entity.x + entity.dx, entity.y + entity.dy)
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_immutable bytes=064 n=$n"] = @be setup_immutable_64B($n) benchmark_immutable_64B(_, $n) seconds = SECONDS
end

function setup_immutable_128B(n_entities::Int)
    vec = Vector{AosImmutable_128B}()
    for _ in 1:n_entities
        push!(vec, AosImmutable_128B())
    end
    return vec
end

function benchmark_immutable_128B(args, n)
    vec = args
    @inbounds for (i, entity) in enumerate(vec)
        vec[i] = AosImmutable_128B(entity.x + entity.dx, entity.y + entity.dy)
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_immutable bytes=128 n=$n"] = @be setup_immutable_128B($n) benchmark_immutable_128B(_, $n) seconds = SECONDS
end
