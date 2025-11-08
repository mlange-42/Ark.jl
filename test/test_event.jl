@testset "Event type creation" begin
    reg = EventRegistry()

    e1 = new_event_type!(reg)
    e2 = new_event_type!(reg)
    @test e1._id == 5
    @test e2._id == 6

    while true
        e = new_event_type!(reg)
        if e._id == typemax(UInt8)
            break
        end
    end
    @test_throws "InvalidStateException: reached maximum number of 255 event types" new_event_type!(reg)

    @test OnCreateEntity._id == 1
    @test OnRemoveEntity._id == 2
    @test OnAddComponents._id == 3
    @test OnRemoveComponents._id == 4
end

@testset "Observer creation" begin
    world = World(Position, Velocity, Altitude, Health)

    obs = @observe!(world, OnAddComponents, (Position, Velocity)) do entity
        println(entity)
    end

    M = (@isdefined fake_types) ? 2 : 1
    @test obs._comps == _Mask{M}(1, 2)
    @test obs._with == _Mask{M}()
    @test obs._without == _Mask{M}()
    @test obs._has_comps == true
    @test obs._has_with == false
    @test obs._has_without == false

    obs = @observe!(world, OnAddComponents, (Position, Velocity);
        with=(Altitude,),
        without=(Health,)
    ) do entity
        println(entity)
    end

    @test obs._comps == _Mask{M}(1, 2)
    @test obs._with == _Mask{M}(3)
    @test obs._without == _Mask{M}(4)
    @test obs._has_comps == true
    @test obs._has_with == true
    @test obs._has_without == true

    obs = @observe!(world, OnAddComponents, ();
        with=(Position, Velocity),
        exclusive=true,
    ) do entity
        println(entity)
    end

    @test obs._comps == _Mask{M}()
    @test obs._with == _Mask{M}(1, 2)
    @test obs._without == _Mask{M}(_Not(), 1, 2)
    @test obs._has_comps == false
    @test obs._has_with == true
    @test obs._has_without == true

    @test_throws(
        "ArgumentError: components tuple must be empty for event types OnCreateEntity and OnRemoveEntity",
        @observe!(world, OnCreateEntity, (Position, Velocity)) do entity
            println(entity)
        end,
    )
end

@testset "Observer registration" begin
    world = World(Position, Velocity, Altitude, Health)
    @test _has_observers(world._event_manager, OnAddComponents) == false
    @test _has_observers(world._event_manager, OnRemoveComponents) == false

    @observe!(world, OnAddComponents, ()) do entity
        println(entity)
    end
    obs1 = @observe!(world, OnAddComponents, ()) do entity
        println(entity)
    end

    @test obs1._id.id == 2
    @test obs1._event._id == 3
    @test length(world._event_manager.observers) == typemax(UInt8)
    @test length(world._event_manager.observers[OnAddComponents._id]) == 2
    @test length(world._event_manager.observers[OnRemoveComponents._id]) == 0
    @test _has_observers(world._event_manager, OnAddComponents) == true
    @test _has_observers(world._event_manager, OnRemoveComponents) == false

    obs2 = @observe!(world, OnAddComponents, (Position,)) do entity
        println(entity)
    end

    @test obs2._id.id == 3
    @test length(world._event_manager.observers[OnAddComponents._id]) == 3

    @test_throws "InvalidStateException: observer is already registered" observe!(world, obs1)

    observe!(world, obs1, unregister=true)
    @test obs1._id.id == 0
    @test obs2._id.id == 2
    @test length(world._event_manager.observers[OnAddComponents._id]) == 2

    obs2 = @observe!(world, OnAddComponents, (); with=(Position,)) do entity
        println(entity)
    end
    observe!(world, obs2, unregister=true)

    @test_throws "InvalidStateException: observer is not registered" observe!(world, obs1, unregister=true)

    obs3 = @observe!(world, OnAddComponents, (); register=false) do entity
        println(entity)
    end
    @test obs3._id.id == 0
    @test length(world._event_manager.observers[OnAddComponents._id]) == 2

    @test length(world._event_manager.observers[OnRemoveComponents._id]) == 0
    @test _has_observers(world._event_manager, OnRemoveComponents) == false
    obs4 = @observe!(world, OnRemoveComponents, ()) do entity
        println(entity)
    end
    @test length(world._event_manager.observers[OnRemoveComponents._id]) == 1
    @test _has_observers(world._event_manager, OnRemoveComponents) == true

    obs5 = @observe!(world, OnRemoveComponents, (Position,)) do entity
        println(entity)
    end
    obs6 = @observe!(world, OnRemoveComponents, (); with=(Position,)) do entity
        println(entity)
    end
    @test length(world._event_manager.observers[OnRemoveComponents._id]) == 3
    observe!(world, obs4, unregister=true)
    observe!(world, obs6, unregister=true)
    observe!(world, obs5, unregister=true)
    @test _has_observers(world._event_manager, OnRemoveComponents) == false
end

@testset "Observer exclusive error" begin
    world = World()
    @test_throws("ArgumentError: cannot use 'exclusive' together with 'without'",
        @observe!(world, OnCreateEntity, (); without=(Altitude,), exclusive=true) do entity
        end
    )
end

@testset "Observer macro missing argument" begin
    ex = Meta.parse("@observe!(world)")
    @test_throws LoadError eval(ex)
end

@testset "Observer macro unknown argument" begin
    ex = Meta.parse("@observe!(world, OnCreateEntity, (), abc = 2) do entity end")
    @test_throws LoadError eval(ex)
end

@testset "Observer macro invalid syntax" begin
    ex = Meta.parse("@observe!(world, OnCreateEntity, (), xyz) do entity end")
    @test_throws LoadError eval(ex)
end

@testset "Fire OnCreateEntity" begin
    world = World(Position, Velocity, Altitude)

    counter = 0
    obs = @observe!(world, OnCreateEntity) do entity
        @test is_alive(world, entity) == true
        @test is_locked(world) == false
        counter += 1
    end
    counter_remove = 0
    @observe!(world, OnRemoveEntity) do entity
        counter_remove += 1
    end

    new_entity!(world, (Position(0, 0),))
    @test counter == 1

    observe!(world, obs; unregister=true)

    @observe!(world, OnCreateEntity, (); with=(Position,)) do entity
    end
    obs = @observe!(world, OnCreateEntity, (); with=(Position, Velocity)) do entity
        counter += 1
    end

    new_entity!(world, (Position(0, 0), Velocity(0, 0)))
    @test counter == 2
    new_entity!(world, (Position(0, 0), Velocity(0, 0), Altitude(0)))
    @test counter == 3
    new_entity!(world, (Position(0, 0),))
    @test counter == 3
    new_entity!(world, (Altitude(0),))
    @test counter == 3

    observe!(world, obs; unregister=true)

    obs = @observe!(world, OnCreateEntity; with=(Position, Velocity), without=(Altitude,)) do entity
        counter += 1
    end
    new_entity!(world, (Position(0, 0), Velocity(0, 0)))
    @test counter == 4
    new_entity!(world, (Position(0, 0), Velocity(0, 0), Altitude(0)))
    @test counter == 4

    @test counter_remove == 0
end

@testset "Fire OnCreateEntity batch" begin
    world = World(Position, Velocity, Altitude)

    counter = 0
    obs = @observe!(world, OnCreateEntity) do entity
        @test is_alive(world, entity) == true
        @test is_locked(world) == true
        counter += 1
    end

    for (p, v) in @new_entities!(world, 10, (Position, Velocity))
    end
    @test counter == 10

    new_entities!(world, 10, (Position(0, 0), Velocity(0, 0)))
    @test counter == 20

    for (p, v) in new_entities!(world, 10, (Position(0, 0), Velocity(0, 0)); iterate=true)
    end
    @test counter == 30

    observe!(world, obs; unregister=true)

    @observe!(world, OnCreateEntity, (); with=(Position,)) do entity
    end
    obs = @observe!(world, OnCreateEntity; with=(Position, Velocity)) do entity
        counter += 1
    end

    new_entities!(world, 10, (Position(0, 0), Velocity(0, 0)))
    @test counter == 40
    new_entities!(world, 10, (Position(0, 0), Velocity(0, 0), Altitude(0)))
    @test counter == 50
    new_entities!(world, 10, (Position(0, 0),))
    @test counter == 50
    new_entities!(world, 10, (Altitude(0),))
    @test counter == 50

    observe!(world, obs; unregister=true)

    obs = @observe!(world, OnCreateEntity; with=(Position, Velocity), without=(Altitude,)) do entity
        counter += 1
    end
    new_entities!(world, 10, (Position(0, 0), Velocity(0, 0)))
    @test counter == 60
    new_entities!(world, 10, (Position(0, 0), Velocity(0, 0), Altitude(0)))
    @test counter == 60
end

@testset "Fire OnRemoveEntity" begin
    world = World(Position, Velocity, Altitude)

    counter = 0
    obs = @observe!(world, OnRemoveEntity) do entity
        @test is_alive(world, entity) == true
        @test is_locked(world) == true
        counter += 1
    end

    remove_entity!(world, new_entity!(world, (Position(0, 0),)))
    @test counter == 1

    observe!(world, obs; unregister=true)

    obs = @observe!(world, OnRemoveEntity; with=(Position, Velocity)) do entity
        counter += 1
    end

    remove_entity!(world, new_entity!(world, (Position(0, 0), Velocity(0, 0))))
    @test counter == 2
    remove_entity!(world, new_entity!(world, (Position(0, 0), Velocity(0, 0), Altitude(0))))
    @test counter == 3
    remove_entity!(world, new_entity!(world, (Position(0, 0),)))
    @test counter == 3
    remove_entity!(world, new_entity!(world, (Altitude(0),)))
    @test counter == 3

    observe!(world, obs; unregister=true)

    obs = @observe!(world, OnRemoveEntity; with=(Position, Velocity), without=(Altitude,)) do entity
        counter += 1
    end
    remove_entity!(world, new_entity!(world, (Position(0, 0), Velocity(0, 0))))
    @test counter == 4
    remove_entity!(world, new_entity!(world, (Position(0, 0), Velocity(0, 0), Altitude(0))))
    @test counter == 4
end

@testset "Fire OnAddComponents/OnRemoveComponents" begin
    world = World(Position, Velocity, Altitude, Health)

    counter_add = 0
    counter_rem = 0
    obs_add = @observe!(world, OnAddComponents) do entity
        @test is_alive(world, entity) == true
        @test is_locked(world) == false
        counter_add += 1
    end
    obs_rem = @observe!(world, OnRemoveComponents) do entity
        @test is_alive(world, entity) == true
        @test is_locked(world) == true
        counter_rem += 1
    end

    e = new_entity!(world, ())
    add_components!(world, e, (Position(0, 0),))
    @test counter_add == 1
    @test counter_rem == 0
    @remove_components!(world, e, (Position,))
    @test counter_add == 1
    @test counter_rem == 1

    observe!(world, obs_add; unregister=true)
    observe!(world, obs_rem; unregister=true)

    obs_add = @observe!(world, OnAddComponents, (Position, Velocity)) do entity
        counter_add += 1
    end
    obs_rem = @observe!(world, OnRemoveComponents, (Position, Velocity)) do entity
        counter_rem += 1
    end
    obs_add_dummy = @observe!(world, OnAddComponents, (Position,)) do entity
    end
    obs_rem_dummy = @observe!(world, OnRemoveComponents, (Position,)) do entity
    end

    e = new_entity!(world, ())
    add_components!(world, e, (Position(0, 0), Velocity(0, 0)))
    @remove_components!(world, e, (Position, Velocity))
    @test counter_add == 2
    @test counter_rem == 2

    add_components!(world, e, (Altitude(0),))
    @remove_components!(world, e, (Altitude,))
    @test counter_add == 2
    @test counter_rem == 2

    add_components!(world, e, (Position(0, 0),))
    @remove_components!(world, e, (Position,))
    @test counter_add == 2
    @test counter_rem == 2
end

@testset "Fire OnAddComponents/OnRemoveComponents with" begin
    world = World(Position, Velocity, Altitude, Health)

    counter_add = 0
    counter_rem = 0
    obs_add = @observe!(world, OnAddComponents, (); with=(Position, Velocity)) do entity
        counter_add += 1
    end
    obs_rem = @observe!(world, OnRemoveComponents, (); with=(Position, Velocity)) do entity
        counter_rem += 1
    end
    obs_add_dummy = @observe!(world, OnAddComponents, (); with=(Position,)) do entity
    end
    obs_rem_dummy = @observe!(world, OnRemoveComponents, (); with=(Position,)) do entity
    end

    e = new_entity!(world, (Position(0, 0), Velocity(0, 0)))
    add_components!(world, e, (Health(0),))
    @remove_components!(world, e, (Health,))
    @test counter_add == 1
    @test counter_rem == 1

    e = new_entity!(world, (Altitude(0),))
    add_components!(world, e, (Health(0),))
    @remove_components!(world, e, (Health,))
    @test counter_add == 1
    @test counter_rem == 1

    e = new_entity!(world, (Position(0, 0),))
    add_components!(world, e, (Health(0),))
    @remove_components!(world, e, (Health,))
    @test counter_add == 1
    @test counter_rem == 1
end

@testset "Fire OnAddComponents/OnRemoveComponents without" begin
    world = World(Position, Velocity, Altitude, Health)

    counter_add = 0
    counter_rem = 0
    obs_add = @observe!(world, OnAddComponents, (); without=(Position, Velocity)) do entity
        counter_add += 1
    end
    obs_rem = @observe!(world, OnRemoveComponents, (); without=(Position, Velocity)) do entity
        counter_rem += 1
    end
    obs_add_dummy = @observe!(world, OnAddComponents, (); without=(Position,)) do entity
    end
    obs_rem_dummy = @observe!(world, OnRemoveComponents, (); without=(Position,)) do entity
    end

    e = new_entity!(world, (Altitude(0),))
    add_components!(world, e, (Health(0),))
    @remove_components!(world, e, (Health,))
    @test counter_add == 1
    @test counter_rem == 1

    e = new_entity!(world, (Position(0, 0),))
    add_components!(world, e, (Health(0),))
    @remove_components!(world, e, (Health,))
    @test counter_add == 1
    @test counter_rem == 1

    e = new_entity!(world, (Position(0, 0), Velocity(0, 0)))
    add_components!(world, e, (Health(0),))
    @remove_components!(world, e, (Health,))
    @test counter_add == 1
    @test counter_rem == 1
end

@testset "Observers combine" begin
    world = World(Position, Velocity)

    counter = 0
    fn = (event::EventType, entity::Entity) -> begin
        counter += 1
    end
    obs_add = @observe!(world, OnCreateEntity) do entity
        fn(OnCreateEntity, entity)
    end
    obs_rem = @observe!(world, OnRemoveEntity) do entity
        fn(OnRemoveEntity, entity)
    end

    e = new_entity!(world, ())
    @test counter == 1
    remove_entity!(world, e)
    @test counter == 2
end

@testset "Fire custom event" begin
    reg = EventRegistry()
    OnUpdateComponents = new_event_type!(reg)
    world = World(Position, Velocity, Altitude, Health)

    e = new_entity!(world, ())
    @emit_event!(world, OnUpdateComponents, e)

    counter = 0
    obs = @observe!(world, OnUpdateComponents) do entity
        if counter == 0
            @test is_zero(entity) == true
        else
            @test is_alive(world, entity) == true
        end
        @test is_locked(world) == false
        counter += 1
    end

    @emit_event!(world, OnUpdateComponents, zero_entity)
    @test counter == 1

    e = new_entity!(world, (Position(0, 0),))
    @emit_event!(world, OnUpdateComponents, e, (Position,))
    @test counter == 2

    observe!(world, obs; unregister=true)

    obs = @observe!(world, OnUpdateComponents, (Position, Velocity)) do entity
        counter += 1
    end
    obs_dummy = @observe!(world, OnUpdateComponents, (Position,)) do entity
    end

    e = new_entity!(world, (Position(0, 0), Velocity(0, 0), Altitude(0)))
    @emit_event!(world, OnUpdateComponents, e, (Position, Velocity))
    @test counter == 3

    @emit_event!(world, OnUpdateComponents, e, (Altitude,))
    @test counter == 3

    @emit_event!(world, OnUpdateComponents, e, (Position,))
    @test counter == 3
end

@testset "Fire custom event with" begin
    reg = EventRegistry()
    OnUpdateComponents = new_event_type!(reg)
    world = World(Position, Velocity, Altitude, Health)

    counter = 0
    obs = @observe!(world, OnUpdateComponents, (); with=(Position, Velocity)) do entity
        counter += 1
    end
    obs_dummy = @observe!(world, OnUpdateComponents, (); with=(Position,)) do entity
    end

    e = new_entity!(world, (Position(0, 0), Velocity(0, 0)))
    @emit_event!(world, OnUpdateComponents, e)
    @test counter == 1

    e = new_entity!(world, (Altitude(0),))
    @emit_event!(world, OnUpdateComponents, e)
    @test counter == 1

    e = new_entity!(world, (Position(0, 0),))
    @emit_event!(world, OnUpdateComponents, e)
    @test counter == 1
end

@testset "Fire custom event without" begin
    reg = EventRegistry()
    OnUpdateComponents = new_event_type!(reg)
    world = World(Position, Velocity, Altitude, Health)

    counter = 0
    obs = @observe!(world, OnUpdateComponents, (); without=(Position, Velocity)) do entity
        counter += 1
    end
    obs_dummy = @observe!(world, OnUpdateComponents, (); without=(Position,)) do entity
    end

    e = new_entity!(world, (Altitude(0),))
    @emit_event!(world, OnUpdateComponents, e)
    @test counter == 1

    e = new_entity!(world, (Position(0, 0),))
    @emit_event!(world, OnUpdateComponents, e)
    @test counter == 1

    e = new_entity!(world, (Position(0, 0), Velocity(0, 0)))
    @emit_event!(world, OnUpdateComponents, e)
    @test counter == 1
end

@testset "Fire custom event errors" begin
    reg = EventRegistry()
    OnUpdateComponents = new_event_type!(reg)
    world = World(Position, Velocity, Altitude, Health)
    @observe!(world, OnUpdateComponents, ()) do entity
    end

    e = new_entity!(world, (Position(0, 0), Velocity(0, 0)))

    @test_throws("ArgumentError: only custom events can be emitted manually",
        @emit_event!(world, OnCreateEntity, e, ()))
    @test_throws("ArgumentError: can't emit event with components for the zero entity",
        @emit_event!(world, OnUpdateComponents, zero_entity, (Position,)))

    remove_entity!(world, e)
    @test_throws("ArgumentError: can't emit event for a dead entity",
        @emit_event!(world, OnUpdateComponents, e, ()))

    e = new_entity!(world, (Position(0, 0), Velocity(0, 0)))
    @test_throws("ArgumentError: entity does not have all components of the event emitted for it",
        @emit_event!(world, OnUpdateComponents, e, (Position, Altitude)))
end

@testset "@emit_event! macro wrong number of arguments" begin
    ex = Meta.parse("@emit_event!(world, OnUpdateComponents)")
    @test_throws LoadError eval(ex)
end
