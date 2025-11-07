
@testset "Batch iterator test" begin
    world = World(
        Position,
        Velocity => StructArrayStorage,
        Altitude,
    )
    new_entity!(world, (Position(1, 2),))
    new_entity!(world, (Position(1, 2), Velocity(3, 4)))

    storages = (world._storages[1],)
    batch = Batch{typeof(world),Tuple{Position},typeof(world).parameters[3],1}(world,
        [
            _BatchArchetype(world._archetypes[2], 1, 1),
            _BatchArchetype(world._archetypes[3], 1, 1),
        ], _QueryLock(false), _lock(world._lock))

    arches = 0
    for (ent, pos_col) in batch
        @test length(ent) == 1
        @test length(pos_col) == 1
        arches += 1
    end
    @test arches == 2

    # test closed batch
    @test_throws(
        "InvalidStateException: batch closed, batches can't be used multiple times",
        begin
            for x in batch
                nothing
            end
        end
    )

    batch = Batch{typeof(world),Tuple{Position},typeof(world).parameters[3],1}(world,
        [
            _BatchArchetype(world._archetypes[2], 1, 1),
            _BatchArchetype(world._archetypes[3], 1, 1),
        ], _QueryLock(false), _lock(world._lock))

    close!(batch)
    # test closed batch
    @test_throws(
        "InvalidStateException: batch closed, batches can't be used multiple times",
        begin
            for x in batch
                nothing
            end
        end
    )
end
