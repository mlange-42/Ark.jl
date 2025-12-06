
@testset "Cache functionality" begin
    world = World(Dummy, Position, Velocity, ChildOf, Altitude)

    filter1 = Filter(world, (); register=true)
    @test length(world._cache.filters) == 1
    @test length(filter1._filter.tables.tables) == 1
    @test filter1._filter.id[] == 1
    @test world._tables[1].filters.tables == [UInt32(1)]

    filter2 = Filter(world, (Altitude,); register=true)
    @test length(world._cache.filters) == 2
    @test length(filter2._filter.tables.tables) == 0
    @test filter2._filter.id[] == 2

    parent = new_entity!(world, ())
    e1 = new_entity!(world, (Position(0, 0), Velocity(0, 0)))

    @test length(filter1._filter.tables.tables) == 2

    filter3 = Filter(world, (Position, Velocity); register=true)
    @test length(world._cache.filters) == 3
    @test length(filter3._filter.tables.tables) == 1
    @test filter3._filter.id[] == 3

    unregister(filter1)
    @test world._cache.free_indices == [UInt32(1)]
    @test length(filter1._filter.tables.tables) == 0
    @test filter1._filter.id[] == 0
    @test world._tables[1].filters.tables == []

    unregister(filter3)
    @test world._cache.free_indices == [UInt32(1)]
    @test length(world._cache.filters) == 2
    @test length(filter3._filter.tables.tables) == 0

    @test_throws(
        "InvalidStateException: filter is not registered to the cache",
        unregister(filter3)
    )

    filter3 = Filter(world, (Position, Velocity); register=true)
    @test length(world._cache.filters) == 2
    @test length(filter3._filter.tables.tables) == 1
    @test filter3._filter.id[] == 1
end

@testset "Cache functionality relations" begin end
