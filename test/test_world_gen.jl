using .TestTypes: Position, Velocity, Altitude, Health

@testset "World creation" begin
    world = WorldGen(Position, Velocity)
    @test isa(world, WorldGen)

    @test _component_id(world, Velocity) == 2
    @test _component_id(world, Position) == 1
    @test_throws ErrorException _component_id(world, Altitude)

    @test isa(_get_storage(world, Position), _ComponentStorage{Position})
    @test isa(_get_storage(world, Val{Position}()), _ComponentStorage{Position})
    @test isa(_get_storage_by_id(world, Val(1)), _ComponentStorage{Position})
end
