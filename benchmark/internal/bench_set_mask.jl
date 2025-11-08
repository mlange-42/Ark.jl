using Ark: _Mask, _MutableMask, _set_mask!

function setup_set_mask()
    mask_a = _Mask{4}(1, 65, 129, 193, 194, 195)
    mask_b = _MutableMask{4}()
    return mask_a, mask_b
end

function benchmark_set_mask(args)
    mask_a, mask_b = args
    _set_mask!(mask_b, mask_a)
    return
end

SUITE["benchmark_set_mask n=1"] = @be setup_set_mask() benchmark_set_mask(_) seconds = SECONDS
