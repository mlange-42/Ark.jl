using Ark
using Test

@testset "_VecMap basic functionality" begin
    # Create a new map
    map = _VecMap{Int}()

    # Initially, getting any index should return nothing
    @test _get_map(map, UInt8(1)) === nothing

    # Set a value at index 1
    _set_map!(map, UInt8(1), 42)
    @test _get_map(map, UInt8(1)) == 42

    # Set a value beyond initial capacity to trigger resize
    idx = UInt8(20)
    _set_map!(map, idx, 99)
    @test _get_map(map, idx) == 99
    @test length(map.data) >= idx

    # Ensure other unset indices still return nothing
    @test _get_map(map, UInt8(2)) === nothing
end