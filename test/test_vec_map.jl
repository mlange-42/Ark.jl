
@testset "_VecMap basic functionality" begin
    # Create a new map
    map = _VecMap{Int,4}()

    # Initially, no index should be in map
    @test _in_map(map, 1) == false

    # Set a value at index 1
    _set_map!(map, 1, 42)
    @test _get_map(map, 1) == 42

    # Set a value beyond initial capacity to trigger resize
    idx = 20
    _set_map!(map, idx, 99)
    @test _get_map(map, idx) == 99
    @test _in_map(map, idx) == true

    # Ensure other unset indices still return nothing
    @test _in_map(map, 2) == false
end
