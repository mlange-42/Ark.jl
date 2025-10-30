
function setup_flat_2(n_entities::Int)
    vec = Vector{AosFlat2}()
    for _ in 1:n_entities
        push!(vec, AosFlat2())
    end
    return vec
end

function benchmark_flat_2(args, n)
    vec = args
    @inbounds for entity in vec
        entity.x += entity.dx
        entity.y += entity.dy
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_flat_2 n=$n"] = @be setup_flat_2($n) benchmark_flat_2(_, $n) seconds = SECONDS
end

function setup_flat_4(n_entities::Int)
    vec = Vector{AosFlat4}()
    for _ in 1:n_entities
        push!(vec, AosFlat4())
    end
    return vec
end

function benchmark_flat_4(args, n)
    vec = args
    @inbounds for entity in vec
        entity.x += entity.dx
        entity.y += entity.dy
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_flat_4 n=$n"] = @be setup_flat_4($n) benchmark_flat_4(_, $n) seconds = SECONDS
end

function setup_flat_8(n_entities::Int)
    vec = Vector{AosFlat8}()
    for _ in 1:n_entities
        push!(vec, AosFlat8())
    end
    return vec
end

function benchmark_flat_8(args, n)
    vec = args
    @inbounds for entity in vec
        entity.x += entity.dx
        entity.y += entity.dy
    end
    return vec
end

for n in (100, 1_000, 10_000, 100_000, 1_000_000)
    SUITE["benchmark_flat_8 n=$n"] = @be setup_flat_8($n) benchmark_flat_8(_, $n) seconds = SECONDS
end
