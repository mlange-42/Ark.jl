using Ark
using Test

using .TestTypes: Position, Velocity

@testset "Map new/get/set" begin
    world = World()
    m = Map2{Position,Velocity}(world)

    entity = new_entity!(m, Position(1, 2), Velocity(3, 4))
    @test entity == _new_entity(2, 0)
    @test is_alive(world, entity) == true
    pos, vel = get_components(m, entity)
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)

    set_components!(m, entity, Position(5, 6), Velocity(7, 8))
    pos, vel = get_components(m, entity)
    @test pos == Position(5, 6)
    @test vel == Velocity(7, 8)

    empty_entity = new_entity!(world)
    @test_throws MethodError get_components(m, empty_entity)
    @test_throws MethodError set_components!(m, empty_entity, Position(5, 6), Velocity(7, 8))
end
