
using Random
using Ark: _Linear_Map, _Mask

function setup_get!_map(n)
    map = _Linear_Map{_Mask{1},Int}(ceil(Int, 1.36 * n))
    rands = [_Mask((UInt64(x),)) for x in 1:n]
    shuffle!(Xoshiro(42), rands)
    return map, rands
end

function benchmark_get!_map(args)
    map, rands = args
    s = 0
    for r in rands
        s += get!(() -> 1, map, r)
    end
    return s
end

for n in (100, 10000)
    SUITE["benchmark_get!_map n=$n"] = @be setup_get!_map(n) benchmark_get!_map(_) evals = 1 seconds = SECONDS
end

function setup_get_map(n)
    map = _Linear_Map{_Mask{1},Int}(n)
    rands = [_Mask((UInt64(x),)) for x in 1:n]
    shuffle!(Xoshiro(42), rands)
    for r in rands
        get!(() -> 1, map, r)
    end
    return map, rands
end

function benchmark_get_map(args)
    map, rands = args
    s = 0
    for r in rands
        s += get!(() -> 1, map, r)
    end
    return s
end

for n in (100, 10000)
    SUITE["benchmark_get_map n=$n"] = @be setup_get_map(n) benchmark_get_map(_) seconds = SECONDS
end
