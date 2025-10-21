using .TestTypes: Position, Velocity, Altitude, Health

@testset "World creation" begin
    world = WorldGen(Position, Velocity)
    @test isa(world, WorldGen)
    @test _component_id!(world, Velocity) == 2
    @test _component_id!(world, Position) == 1
end
