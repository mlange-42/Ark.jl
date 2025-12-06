
@testset "Filter basic functionality" begin
    world = World(Dummy, Position, Velocity, Altitude, Health)

    f1 = Filter(world, (Position, Velocity))
    f2 = Filter(world, (Position, Velocity); with=(Altitude,))
    f3 = Filter(world, (Position, Velocity); without=(Altitude,))
    f4 = Filter(world, (Position, Velocity); exclusive=true)

    f5 = Filter(world, (Position, Velocity); cached=true)
    @test length(world._cache.filters) == 1

    e = new_entity!(world, (Position(0, 0), Velocity(0, 0)))
    @test length(f5._filter.tables.tables) == 1
end

@testset "Filter show" begin
    world = World(
        Position,
        Velocity,
        Altitude,
        Health,
        CompN{1},
    )
    filter = Filter(world, (Position, Velocity))
    @test string(filter) == "Filter((Position, Velocity))"

    filter = Filter(world, (Position, Velocity); optional=(Altitude,), with=(Health,), exclusive=true)
    @test string(filter) == "Filter((Position, Velocity); optional=(Altitude), with=(Health), exclusive=true)"

    filter = Filter(world, (Position, Velocity); optional=(Altitude,), without=(Health,))
    @test string(filter) == "Filter((Position, Velocity); optional=(Altitude), without=(Health))"

    filter = Filter(world, (Position, Velocity); cached=true)
    @test string(filter) == "Filter((Position, Velocity); cached=true)"
end
