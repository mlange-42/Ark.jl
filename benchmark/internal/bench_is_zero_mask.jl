using Ark: _Mask, _MutableMask, _is_zero

function setup_is_zero_mask()
    return _Mask{4}(1, 65, 129, 193, 194, 195)
end

function benchmark_is_zero_mask(args)
    mask = args
    return _is_zero(mask)
end

SUITE["benchmark_is_zero_mask n=1"] = @be setup_is_zero_mask() benchmark_is_zero_mask(_) seconds = SECONDS
