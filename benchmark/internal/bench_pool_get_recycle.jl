using Ark: _EntityPool, _get_entity, _recycle

function setup_pool_get_recycle(n::Int)
    pool = _EntityPool(UInt32(64))
    e = _get_entity(pool)
    _recycle(pool, e)

    return pool
end

function benchmark_pool_get_recycle(args, n)
    pool = args
    for i in 1:n
        e = _get_entity(pool)
        _recycle(pool, e)
    end
    return pool
end

SUITE["benchmark_pool_get_recycle n=1000"] =
    @be setup_pool_get_recycle(1000) benchmark_pool_get_recycle(_, 1000) seconds = SECONDS
