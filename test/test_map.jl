using Ark
using Test

using .TestTypes: Position, Velocity

@testset "Map operations" begin
    world = World()
    m = Map2{Position,Velocity}(world)

    entity = new_entity!(m, Position(1, 2), Velocity(3, 4))

    pos, vel = get_components(m, entity)
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)
end
