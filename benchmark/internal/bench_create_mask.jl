using Ark: _Mask, _set_mask!

function setup_create_mask()
    return [(rand(1:256), rand(1:256), rand(1:256), rand(1:256)) for _ in 1:1000]
end

function benchmark_create_mask(args)
    inds = args
    b = UInt64(0)
    for (i1, i2, i3, i4) in inds
        b &= _Mask{4}(i1, i2, i3, i4).bits[1]
    end
    return b
end

SUITE["benchmark_create_mask n=1000"] = @be setup_create_mask() benchmark_create_mask(_) seconds = SECONDS
