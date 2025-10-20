using Ark
using Test

@testset "_Lock functionality" begin
    lock = _Lock()

    # Initially, nothing should be locked
    @test !_is_locked(lock)
    @test lock.lock_bits == 0

    # Lock a bit
    b1 = _lock(lock)
    @test _is_locked(lock)
    @test ((lock.lock_bits >> (b1 - 1)) & 0x01) == 1

    # Lock another bit
    b2 = _lock(lock)
    @test b2 != b1
    @test ((lock.lock_bits >> (b2 - 1)) & 0x01) == 1

    # Unlock first bit
    _unlock(lock, b1)
    @test ((lock.lock_bits >> (b1 - 1)) & 0x01) == 0
    @test _is_locked(lock)  # still locked because b2 is active

    # Unlock second bit
    _unlock(lock, b2)
    @test !_is_locked(lock)
    @test lock.lock_bits == 0

    # Unlocking an already unlocked bit should throw
    @test_throws ErrorException _unlock(lock, b1)
end