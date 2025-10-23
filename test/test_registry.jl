
@testset "ComponentRegistry Tests" begin
    registry = _ComponentRegistry()

    # Register new types
    id_int = _register_component!(registry, Int)
    id_float = _register_component!(registry, Float64)
    id_pos = _register_component!(registry, Position)

    # Check that IDs are UInt8 and unique
    @test isa(id_int, UInt8)
    @test isa(id_float, UInt8)
    @test isa(id_pos, UInt8)
    @test id_int != id_float != id_pos

    @test _get_id!(registry, Int) == id_int

    @test_throws ErrorException _get_id!(registry, String)
end
