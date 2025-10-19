using Ark
using Test

using .TestTypes: Position, Velocity


@testset "Map creation" begin
    world = World()
    m = Map2{Position,Velocity}(world)

    entity = new_entity2(m, Position(1, 2), Velocity(3, 4))

    pos, vel = get2(m, entity)
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)
end
