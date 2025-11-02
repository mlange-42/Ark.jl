
@testset "Event type creation" begin
    reg = EventRegistry()

    e1 = new_event_type!(reg)
    e2 = new_event_type!(reg)
    @test e1._id == 3
    @test e2._id == 4

    while true
        e = new_event_type!(reg)
        if e._id == typemax(UInt8)
            break
        end
    end
    @test_throws ErrorException new_event_type!(reg)
end

@testset "Observer creation" begin
    world = World(Position, Velocity, Altitude, Health)

    obs = @observe!(world, OnCreateEntity,
        components = (Position, Velocity),
    ) do entity
        println(entity)
    end

    @test obs._comps == _Mask(1, 2)
    @test obs._with == _Mask()
    @test obs._without == _Mask()
    @test obs._has_excluded == false

    obs = @observe!(world, OnCreateEntity,
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

    obs = @observe!(world, OnCreateEntity,
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
    @test _has_observers(world._event_manager, OnCreateEntity) == false

    obs1 = @observe!(world, OnCreateEntity) do entity
        println(entity)
    end

    @test obs1._id.id == 1
    @test length(world._event_manager.observers) == typemax(UInt8)
    @test length(world._event_manager.observers[OnCreateEntity._id]) == 1
    @test _has_observers(world._event_manager, OnCreateEntity) == true

    obs2 = @observe!(world, OnCreateEntity) do entity
        println(entity)
    end

    @test obs2._id.id == 2
    @test length(world._event_manager.observers[OnCreateEntity._id]) == 2

    @test_throws ErrorException observe!(world, obs1)

    observe!(world, obs1, unregister=true)
    @test obs1._id.id == 0
    @test obs2._id.id == 1
    @test length(world._event_manager.observers[OnCreateEntity._id]) == 1

    @test_throws ErrorException observe!(world, obs1, unregister=true)

    obs3 = @observe!(world, OnCreateEntity, register = false) do entity
        println(entity)
    end
    @test obs3._id.id == 0
    @test length(world._event_manager.observers[OnCreateEntity._id]) == 1
end

@testset "Observer exclusive error" begin
    world = World()
    @test_throws ErrorException @observe!(world, OnCreateEntity, without = (Altitude,), exclusive = true) do entity
    end
end

@testset "Observer macro missing argument" begin
    ex = Meta.parse("@observe!(world)")
    @test_throws LoadError eval(ex)
end

@testset "Observer macro unknown argument" begin
    ex = Meta.parse("@observe!(world, OnCreateEntity, abc = 2) do entity end")
    @test_throws LoadError eval(ex)
end

@testset "Observer macro invalid syntax" begin
    ex = Meta.parse("@observe!(world, OnCreateEntity, xyz) do entity end")
    @test_throws LoadError eval(ex)
end
