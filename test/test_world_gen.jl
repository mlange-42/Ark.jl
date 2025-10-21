using .TestTypes: Position, Velocity, Altitude, Health

@testset "World creation" begin
    world = WorldGen(Position, Velocity)
    @test isa(world, WorldGen)
end
