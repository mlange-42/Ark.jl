using Ark
using Test

using .TestTypes: Position, Velocity, Altitude, Health

@testset "Map new/get/set/has" begin
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

    @test has_components(m, entity) == true
    @test has_components(m, empty_entity) == false
end

@testset "Map add/remove" begin
    world = World()
    m1 = Map2{Position,Velocity}(world)
    m2 = Map2{Altitude,Health}(world)

    e1 = new_entity!(world)
    add_components!(m1, e1, Position(1, 2), Velocity(3, 4))

    @test has_components(m1, e1) == true
    @test has_components(m2, e1) == false

    e2 = new_entity!(m1, Position(5, 6), Velocity(7, 8))

    add_components!(m2, e1, Altitude(1), Health(2))
    @test has_components(m1, e1) == true
    @test has_components(m2, e1) == true

    add_components!(m2, e2, Altitude(3), Health(4))
    @test has_components(m1, e2) == true
    @test has_components(m2, e2) == true

    remove_components!(m1, e1)
    @test has_components(m1, e1) == false
    @test has_components(m2, e1) == true

    a, h = get_components(m2, e1)
    @test a == Altitude(1)
    @test h == Health(2)

    a, h = get_components(m2, e2)
    @test a == Altitude(3)
    @test h == Health(4)
end
