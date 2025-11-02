
@testset "Event type creation" begin
    reg = EventRegistry()

    e1 = new_event_type!(reg)
    e2 = new_event_type!(reg)
    @test e1._id == 3
    @test e2._id == 4
end

@testset "Observer creation" begin
    world = World()

    obs2 = Observer(world, OnCreateEntity) do entity
        println(entity)
    end

    obs2._fn(zero_entity)
end
