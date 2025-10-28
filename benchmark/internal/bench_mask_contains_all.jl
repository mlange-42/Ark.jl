using Ark: _Mask, _contains_all

function setup_mask_contains_all(n::Int)
    mask_a = _Mask(1, 65, 129, 193, 194, 195)
    masks = [
        _Mask(1, 65, 129, 193),
        _Mask(1, 65, 129, 194),
        _Mask(1, 65, 129, 196),
    ]

    return mask_a, masks
end

function benchmark_mask_contains_all(args, n)
    mask_a, masks = args
    len = length(masks)
    b = false
    for i in 1:n
        b = _contains_all(mask_a, masks[i%len+1])
    end
    return b
end

SUITE["benchmark_mask_contains_all n=1000"] = @be setup_mask_contains_all(1000) benchmark_mask_contains_all(_, 1000) seconds = SECONDS

function setup_mask_contains_all_small(n::Int)
    mask_a = _Mask(1)
    masks = [
        _Mask(1),
        _Mask(1),
        _Mask(2),
    ]

    return mask_a, masks
end

function benchmark_mask_contains_all_small(args, n)
    mask_a, masks = args
    len = length(masks)
    b = false
    for i in 1:n
        b = _contains_all(mask_a, masks[i%len+1])
    end
    return b
end

SUITE["benchmark_mask_contains_all_small n=1000"] = @be setup_mask_contains_all_small(1000) benchmark_mask_contains_all_small(_, 1000) seconds = SECONDS
