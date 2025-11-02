
@testset "Batch iterator test" begin
    world = World(Position, Velocity, Altitude)
    add_entity!(world, (Position(1, 2),))
    add_entity!(world, (Position(1, 2), Velocity(3, 4)))

    storages = (world._storages[1],)
    batch = Batch{typeof(world),typeof(storages),1}(world,
        [
            _BatchArchetype(world._archetypes[2], 1, 1),
            _BatchArchetype(world._archetypes[3], 1, 1),
        ], storages, 0, _lock(world._lock))

    arches = 0
    for (ent, pos_col) in batch
        @test length(ent) == 1
        @test length(pos_col) == 1
        arches += 1
    end
    @test arches == 2

    # test closed batch
    @test_throws ErrorException begin
        for x in batch
            nothing
        end
    end
end
