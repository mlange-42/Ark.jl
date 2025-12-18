
@testset "_EntityPool constructor" begin
    initialCap = UInt32(10)
    pool = _EntityPool(initialCap)

    @test isa(pool, _EntityPool)
    @test length(pool.entities) == 1
    @test all(e -> e._gen == typemax(UInt32), pool.entities)
    @test pool.next == 0
end

@testset "_BitPool basic functionality" begin
    pool = _BitPool()

    # Test initial state
    @test pool.bits == 0

    # Allocate a few bits
    b1 = _get_bit(pool)
    b2 = _get_bit(pool)
    b3 = _get_bit(pool)

    @test b1 == 1
    @test b2 == 2
    @test b3 == 3
    @test count_ones(pool.bits) == 3

    # Recycle one bit
    _recycle(pool, b2)
    @test count_ones(pool.bits) == 2

    # Reuse recycled bit
    reused = _get_bit(pool)
    @test count_ones(pool.bits) == 3

    # Fill up to 64 bits
    for _ in 1:(64-pool.length)
        _get_bit(pool)
    end
    @test count_ones(pool.bits) == 64

    # Test overflow error
    @test_throws(
        "InvalidStateException: run out of the maximum of 64 bits. " *
        "This is likely caused by unclosed queries that lock the world. " *
        "Make sure that all queries finish their iteration or are closed manually",
        _get_bit(pool)
    )
end
