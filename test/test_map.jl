
@testset "Map new/get/set/has" begin
    world = World(Position, Velocity)
    m = @Map(world, (Position, Velocity))

    @test_throws ErrorException Map(world, Val.((Position, Velocity, Altitude)))

    entity = new_entity!(m, (Position(1, 2), Velocity(3, 4)))
    @test entity == _new_entity(2, 0)
    @test is_alive(world, entity) == true
    pos, vel = m[entity]
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)

    m[entity] = (Position(5, 6), Velocity(7, 8))
    pos, vel = m[entity]
    @test pos == Position(5, 6)
    @test vel == Velocity(7, 8)

    empty_entity = new_entity!(world)
    # TODO: do we want that, or do we want it to return `nothing`?
    @test_throws FieldError m[empty_entity]
    @test_throws FieldError m[empty_entity] = (Position(5, 6), Velocity(7, 8))

    @test_throws ErrorException m[zero_entity]
    @test_throws ErrorException m[zero_entity] = (Position(5, 6), Velocity(7, 8))
    @test_throws ErrorException has_components(m, zero_entity)
    @test_throws ErrorException add_components!(m, zero_entity, (Position(0, 0),))
    @test_throws ErrorException remove_components!(m, zero_entity)

    @test has_components(m, entity) == true
    @test has_components(m, empty_entity) == false
end

@testset "Map add/remove" begin
    world = World(Position, Velocity, Altitude, Health)
    m1 = Map(world, Val.((Position, Velocity)))
    m2 = Map(world, Val.((Altitude, Health)))

    e1 = new_entity!(world)
    add_components!(m1, e1, (Position(1, 2), Velocity(3, 4)))

    @test has_components(m1, e1) == true
    @test has_components(m2, e1) == false

    e2 = new_entity!(m1, (Position(5, 6), Velocity(7, 8)))

    add_components!(m2, e1, (Altitude(1), Health(2)))
    @test has_components(m1, e1) == true
    @test has_components(m2, e1) == true

    add_components!(m2, e2, (Altitude(3), Health(4)))
    @test has_components(m1, e2) == true
    @test has_components(m2, e2) == true

    remove_components!(m1, e1)
    @test has_components(m1, e1) == false
    @test has_components(m2, e1) == true

    a, h = m2[e1]
    @test a == Altitude(1)
    @test h == Health(2)

    a, h = m2[e2]
    @test a == Altitude(3)
    @test h == Health(4)
end
