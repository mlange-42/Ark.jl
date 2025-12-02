
using Random
using Ark: _Mask_Map, _Mask

function setup_get!_map(n)
    map = _Mask_Map{1,Int}(n)
    rands = [_Mask((UInt64(x),)) for x in rand(Xoshiro(42), 1:n, 10n)]
    rands = unique(rands)[1:n]
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
    map = _Mask_Map{1,Int}(n)
    rands = [_Mask((UInt64(x),)) for x in rand(Xoshiro(42), 1:n, n)]
    for r in rands
        s += get!(() -> 1, map, r)
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

