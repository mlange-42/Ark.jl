
@testset "Event type creation" begin
    reg = EventRegistry()

    e1 = new_event_type!(reg)
    e2 = new_event_type!(reg)
    @test e1._id == 3
    @test e2._id == 4
end

@testset "Observer creation" begin
    world = World(Position, Velocity, Altitude, Health)

    obs = @Observer(world, OnCreateEntity,
        components = (Position, Velocity),
    ) do entity
        println(entity)
    end

    @test obs._comps == _Mask(1, 2)
    @test obs._with == _Mask()
    @test obs._without == _Mask()
    @test obs._has_excluded == false

    obs = @Observer(world, OnCreateEntity,
        components = (Position, Velocity),
        with = (Altitude,),
        without = (Health,)
    ) do entity
        println(entity)
    end

    @test obs._comps == _Mask(1, 2)
    @test obs._with == _Mask(3)
    @test obs._without == _Mask(4)
    @test obs._has_excluded == true

    obs = @Observer(world, OnCreateEntity,
        with = (Position, Velocity),
        exclusive = true,
    ) do entity
        println(entity)
    end

    @test obs._comps == _Mask()
    @test obs._with == _Mask(1, 2)
    @test obs._without == _MaskNot(1, 2)
    @test obs._has_excluded == true
end

@testset "Observer registration" begin
    world = World(Position, Velocity, Altitude, Health)

    obs1 = @Observer(world, OnCreateEntity) do entity
        println(entity)
    end

    @test obs1._id.id == 1
    @test length(world._event_manager.observers) == 1
    @test length(world._event_manager.observers[OnCreateEntity._id]) == 1

    obs2 = @Observer(world, OnCreateEntity) do entity
        println(entity)
    end

    @test obs2._id.id == 2
    @test length(world._event_manager.observers) == 1
    @test length(world._event_manager.observers[OnCreateEntity._id]) == 2

    @test_throws ErrorException register_observer!(world, obs1)

    unregister_observer!(world, obs1)
    @test obs1._id.id == 0
    @test obs2._id.id == 1
    @test length(world._event_manager.observers[OnCreateEntity._id]) == 1

    @test_throws ErrorException unregister_observer!(world, obs1)

    obs3 = @Observer(world, OnCreateEntity, register = false) do entity
        println(entity)
    end
    @test obs3._id.id == 0
    @test length(world._event_manager.observers[OnCreateEntity._id]) == 1
end
