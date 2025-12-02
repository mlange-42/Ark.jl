
using Random
using Ark: _Mask_Map, _Mask

rng = Xoshiro(42)

function setup_get_map(n)
    map = _Mask_Map{1, Int}()
    rands = [_Mask((UInt64(x),)) for x in rand(rng, 1:n, n))]
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
