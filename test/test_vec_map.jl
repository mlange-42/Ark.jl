
@testset "_VecMap basic functionality" begin
    # Create a new map
    map = _VecMap{4}()

    # Initially, getting any index should return nothing
    @test _get_map(map, 1) === nothing

    # Set a value at index 1
    _set_map!(map, 1, 42)
    @test _get_map(map, 1) == 42

    # Set a value beyond initial capacity to trigger resize
    idx = 20
    _set_map!(map, idx, 99)
    @test _get_map(map, idx) == 99
    @test length(map.data) >= idx

    # Ensure other unset indices still return nothing
    @test _get_map(map, 2) === nothing
end
