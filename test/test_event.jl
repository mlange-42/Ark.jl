
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
        with = (Altitude,),
        without = (Health,)
    ) do entity
        println(entity)
    end

    @test obs._comps == _Mask(1, 2)
    @test obs._with == _Mask(3)
    @test obs._without == _Mask(4)
    @test obs._exclusive == false

    obs2 = @Observer(world, OnCreateEntity,
        components = (Position, Velocity),
        exclusive = true,
    ) do entity
        println(entity)
    end

    @test obs._comps == _Mask(1, 2)
    @test obs._exclusive == true
end
