using Ark
using Test

using .TestTypes: Position, Velocity

@testset "Map operations" begin
    world = World()
    m = Map2{Position,Velocity}(world)

    entity = new_entity!(m, Position(1, 2), Velocity(3, 4))
    @test entity == _new_entity(1, 0)
    @test is_alive(world, entity) == true
    pos, vel = get_components(m, entity)
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)

    set_components!(m, entity, Position(5, 6), Velocity(7, 8))
    pos, vel = get_components(m, entity)
    @test pos == Position(5, 6)
    @test vel == Velocity(7, 8)
end
