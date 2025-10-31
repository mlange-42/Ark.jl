using Ark: _Mask, _contains_any

function setup_mask_contains_any(n::Int)
    mask_a = _Mask(1, 65, 129, 193, 194, 195)
    masks = [
        _Mask(2, 66, 130, 193),
        _Mask(2, 66, 130, 194),
        _Mask(2, 66, 130, 196),
    ]

    return mask_a, masks
end

function benchmark_mask_contains_any(args, n)
    mask_a, masks = args
    len = length(masks)
    b = false
    for i in 1:n
        b = _contains_any(mask_a, masks[i%len+1])
    end
    return b
end

SUITE["benchmark_mask_contains_any n=1000"] =
    @be setup_mask_contains_any(1000) benchmark_mask_contains_any(_, 1000) seconds = SECONDS

function setup_mask_contains_any_small(n::Int)
    mask_a = _Mask(1)
    masks = [
        _Mask(2),
        _Mask(1),
        _Mask(2),
        _Mask(1),
    ]

    return mask_a, masks
end

function benchmark_mask_contains_any_small(args, n)
    mask_a, masks = args
    len = length(masks)
    b = false
    for i in 1:n
        b = _contains_any(mask_a, masks[i%len+1])
    end
    return b
end

SUITE["benchmark_mask_contains_any_small n=1000"] =
    @be setup_mask_contains_any_small(1000) benchmark_mask_contains_any_small(_, 1000) seconds = SECONDS
