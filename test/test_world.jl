
@testset "World creation" begin
    world = World()
    @test isa(world, World)
    @test isa(world._registry, _ComponentRegistry)

    !(@isdefined fake_types) && @test world._storages == ()
    @test length(world._archetypes) == 1
end

@testset "World creation 2" begin
    world = World(
        Position,
        Velocity => StructArrayStorage,
        Altitude,
        ChildOf,
    )
    @test isa(world, World)
    params = typeof(world).parameters[1]

    @test _component_id(params, Velocity) == offset_ID + 2
    @test _component_id(params, Position) == offset_ID + 1
    @test_throws(
        "ArgumentError: Component type Health not found in the World",
        _component_id(params, Health))

    @test isa(_get_storage(world, Position), _ComponentStorage{Position,Vector{Position}})
    @test isa(_get_storage(world, Position).data[1], Vector{Position})
    @test isa(_get_storage(world, Velocity), _ComponentStorage{Velocity,_StructArray_type(Velocity)})
    @test isa(_get_storage(world, Velocity).data[1], _StructArray{Velocity})
    @test isa(_get_storage(world, Altitude), _ComponentStorage{Altitude,Vector{Altitude}})
    @test isa(_get_storage(world, Altitude).data[1], Vector{Altitude})

    @test length(_get_relations(world, Position).archetypes) == 0
    @test length(_get_relations(world, Position).targets) == 0
    @test length(_get_relations(world, ChildOf).archetypes) == 1
    @test length(_get_relations(world, ChildOf).targets) == 1
    @test _get_relations(world, ChildOf).archetypes[1] == 0
    @test _get_relations(world, ChildOf).targets[1] == _no_entity
end

@testset "World show" begin
    world = World(
        Position,
        Velocity,
        CompN{1},
        CompN{Int64},
        Float64,
    )
    batch = new_entities!(world, 100, (); iterate=false)

    if offset_ID == 0
        @test string(world) == "World(entities=100, comp_types=(Position, Velocity, CompN{1}, CompN{Int64}, Float64))"
    else
        @test startswith(string(world), "World(entities=100, comp_types=(FakeComp{1}, FakeComp{2}, ")
    end
end

@testset "World storage type" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
    )

    @test isa(_get_storage(world, Position), _ComponentStorage{Position,Vector{Position}})
    @test isa(_get_storage(world, Velocity), _ComponentStorage{Velocity,_StructArray_type(Velocity)})
end

"""
@static if "CI" in keys(ENV) && VERSION >= v"1.12.0"
    @testset "World creation JET" begin
        # TODO: type instability here. Add benchmarks for world creation.
        @test_opt World(
            Position,
            Velocity => StructArrayStorage,
        )
    end
end
"""

@testset "World creation error" begin
    @test_throws(
        "ArgumentError: duplicate component type Velocity during world creation",
        World(Position, Velocity, Velocity))

    @test_throws(
        "ArgumentError: can't use VectorStorage as component as it is not a concrete type",
        World(Position, Velocity, VectorStorage))

    @test_throws(
        "ArgumentError: Health is not a valid storage mode, must be StructArrayStorage or VectorStorage",
        World(Position, Velocity, Altitude => Health))

    @test_throws(
        "ArgumentError: can't use StructArrayStorage for Int64 because it has no fields",
        World(Int64 => StructArrayStorage))

    @test_throws(
        "ArgumentError: can't use StructArrayStorage for LabelComponent because it has no fields",
        World(LabelComponent => StructArrayStorage))
end

@testset "World creation large" begin
    world = World(
        CompN{1}, CompN{2}, CompN{3}, CompN{4}, CompN{5},
        CompN{6}, CompN{7}, CompN{8}, CompN{9}, CompN{10},
        CompN{11}, CompN{12}, CompN{13}, CompN{14}, CompN{15},
        CompN{16}, CompN{17}, CompN{18}, CompN{19}, CompN{20},
        CompN{21}, CompN{22}, CompN{23}, CompN{24}, CompN{25},
        CompN{26}, CompN{27}, CompN{28}, CompN{29}, CompN{30},
        Position, Velocity,
    )

    @test length(world._storages) == N_fake + 32
end

@testset "World create table" begin
    world = World(Position, Velocity)

    table1 = _find_or_create_table!(world, world._tables[1], (1,), (), (), ())
    @test table1 == 2
    @test world._tables[table1].archetype == 2
    @test length(world._tables) == 2

    table2 = _find_or_create_table!(world, world._tables[1], (1, 2), (), (), ())
    @test table2 == 3
    @test world._tables[table2].archetype == 3
    @test length(world._tables) == 3

    table3 = _find_or_create_table!(world, world._tables[1], (1,), (), (), ())
    @test table3 == table1
    @test length(world._tables) == 3

    entity, _ = _create_entity!(world, table1)
    _move_entity!(world, entity, table2)
    remove_entity!(world, entity)
end

@testset "World Component Registration" begin
    world = World(Int, Position)
    params = typeof(world).parameters[1]

    # Register Int component
    id_int = _component_id(params, Int)
    @test isa(id_int, Int)
    @test world._registry.types[id_int] == Int
    @test length(world._storages) == N_fake + 2
    @test world._storages[id_int] isa _ComponentStorage{Int,Vector{Int}}
    @test length(world._storages[id_int].data) == 1

    # Register Position component
    id_pos = _component_id(params, Position)
    @test isa(id_pos, Int)
    @test world._registry.types[id_pos] == Position
    @test length(world._storages) == N_fake + 2
    @test world._storages[id_pos] isa _ComponentStorage{Position,Vector{Position}}
    @test length(world._storages[id_pos].data) == 1

    # Re-register Int component (should not add new storage)
    id_int2 = _component_id(params, Int)
    @test id_int2 == id_int
    @test length(world._storages) == N_fake + 2

    @test_throws("ArgumentError: Component type Velocity not found in the World",
        _component_id(params, Velocity))

    @test_throws("ArgumentError: Component type MutableComponent must be immutable unless 'allow_mutable' is used",
        World(Position, MutableComponent))

    _ = World(Position, MutableComponent; allow_mutable=true)

    @test_throws("ArgumentError: Component type MutableComponent must be immutable because it uses StructArray storage",
        World(Position, MutableComponent => StructArrayStorage))
end

@testset "_get_storage Tests" begin
    world = World(Int)
    params = typeof(world).parameters[1]

    storage1 = _get_storage(world, Int)
    @test storage1 isa _ComponentStorage{Int,Vector{Int}}

    id = _component_id(params, Int)
    storage2 = _get_storage(world, Int)
    @test storage2 isa _ComponentStorage{Int,Vector{Int}}

    @test storage1 === storage2

    @test_throws("ArgumentError: Component type Float64 not found in the World",
        _get_storage(world, Float64))

    @test_throws("ArgumentError: Component type Float64 not found in the World",
        _get_relations(world, Float64))
end

@testset "_find_or_create_table! Tests" begin
    world = World(Position, Velocity)
    params = typeof(world).parameters[1]

    pos_id = _component_id(params, Position)
    @test pos_id == offset_ID + UInt8(1)

    index = _find_or_create_table!(world, world._tables[1], (pos_id,), (), (), ())
    @test index == 2
    @test length(world._tables) == 2
    @test length(world._archetypes) == 2

    vel_id = _component_id(params, Velocity)
    @test vel_id == offset_ID + UInt8(2)

    index = _find_or_create_table!(world, world._tables[1], (pos_id, vel_id), (), (), ())
    @test index == 3
    @test length(world._tables) == 3
    @test length(world._archetypes) == 3

    index = _find_or_create_table!(world, world._tables[1], (pos_id, vel_id), (), (), ())
    @test index == 3
    @test length(world._tables) == 3
    @test length(world._archetypes) == 3

    @test world._archetypes[2].components == [pos_id]
    @test world._archetypes[3].components == [pos_id, vel_id]

    @test length(world._storages) == N_fake + 2
    @test length(world._registry.types) == N_fake + 2

    pos_storage = _get_storage(world, Position)
    vel_storage = _get_storage(world, Velocity)

    @test isa(pos_storage, _ComponentStorage{Position,Vector{Position}})
    @test isa(vel_storage, _ComponentStorage{Velocity,Vector{Velocity}})
    @test length(pos_storage.data) == 3
    @test length(vel_storage.data) == 3
end

@testset "_create_entity! Tests" begin
    world = World(Position, Velocity)
    params = typeof(world).parameters[1]
    pos_id = _component_id(params, Position)
    vel_id = _component_id(params, Velocity)
    node = first(world._graph.nodes)[2]

    table_index = _find_or_create_table!(world, world._tables[1], (pos_id, vel_id), (), (), ())
    @test table_index == 2

    entity, index = _create_entity!(world, table_index)
    @test entity == _new_entity(2, 0)
    @test index == 1
    @test world._entities == [_EntityIndex(typemax(UInt32), 0), _EntityIndex(table_index, UInt32(1))]

    remove_entity!(world, entity)
    entity, index = _create_entity!(world, table_index)
    @test entity == _new_entity(2, 1)

    pos_storage = _get_storage(world, Position)
    vel_storage = _get_storage(world, Velocity)

    @test length(pos_storage.data[table_index]) == 1
    @test length(vel_storage.data[table_index]) == 1
end

@testset "World get/set components" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
    )

    e1 = new_entity!(world, (Position(1, 2), Velocity(3, 4)))
    e2 = new_entity!(world, ())

    pos, vel = get_components(world, e1, (Position, Velocity))
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)

    # TODO: do we want that, or do we want it to return `nothing`?
    @test_throws("ArgumentError: entity has no Position component",
        get_components(world, e2, (Position, Velocity)))
    @test_throws("ArgumentError: entity has no Position component",
        set_components!(world, e2, (Position(0, 0),)))
    @test_throws("ArgumentError: can't get components of a dead entity",
        get_components(world, zero_entity, (Position, Velocity)))

    t = get_components(world, e1, ())
    @test t == ()

    set_components!(world, e1, (Position(5, 6), Velocity(7, 8)))
    pos, vel = get_components(world, e1, (Position, Velocity))
    @test pos == Position(5, 6)
    @test vel == Velocity(7, 8)
end

@static if "CI" in keys(ENV) && VERSION >= v"1.12.0"
    @testset "World get/set components JET" begin
        world = World(
            Position,
            Velocity => StructArrayStorage,
        )
        e1 = new_entity!(world, (Position(1, 2), Velocity(3, 4)))

        #@test_opt get_components(world, e1, (Position, Velocity))
        @test_opt set_components!(world, e1, (Position(5, 6), Velocity(7, 8)))
    end
end

@testset "World new_entity! Tests" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
    )

    entity = new_entity!(world, ())
    @test entity == _new_entity(2, 0)
    @test is_alive(world, entity) == true

    entity = new_entity!(world, (Position(1, 2), Velocity(3, 4)))
    @test entity == _new_entity(3, 0)
    @test is_alive(world, entity) == true
    @test length(world._storages[offset_ID+2].data[2]) == 1
    @test length(world._storages[offset_ID+3].data[2]) == 1

    pos, vel = get_components(world, entity, (Position, Velocity))
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)

    @test_throws(
        "ArgumentError: duplicate component types: Position",
        new_entity!(world, (Position(1, 2), Position(3, 4)))
    )

    remove_entity!(world, entity)
    @test is_alive(world, entity) == false
end

@static if "CI" in keys(ENV) && VERSION >= v"1.12.0"
    @testset "World new_entity! JET" begin
        world = World(
            Position,
            Velocity => StructArrayStorage,
        )

        using FunctionWrappers
        excluded = Set([
            FunctionWrappers.gen_fptr,
            Base.unsafe_convert,
            Base.setproperty!,
        ])
        function_filter(@nospecialize f) = !(f in excluded)

        @test_opt function_filter = function_filter new_entity!(world, (Position(1, 2), Velocity(3, 4)))
    end
end

@testset "World new_entity! relations" begin
    world = World(
        Dummy,
        Position,
        ChildOf,
        Velocity => StructArrayStorage,
    )

    parent1 = new_entity!(world, ())
    parent2 = new_entity!(world, ())
    dead_parent = new_entity!(world, ())
    remove_entity!(world, dead_parent)

    e1 = new_entity!(world, (Position(0, 0), ChildOf()); relations=(ChildOf => parent1,))
    e2 = new_entity!(world, (Position(0, 0), ChildOf()); relations=(ChildOf => parent2,))
    e3 = new_entity!(world, (Position(0, 0), ChildOf()); relations=(ChildOf => parent2,))

    @test length(world._archetypes) == 2
    @test length(world._tables) == 3

    arch = world._archetypes[2]
    @test length(arch.index[1]) == 2
    @test arch.index[1][parent1._id].tables == [world._tables[2]]
    @test arch.index[1][parent2._id].tables == [world._tables[3]]

    @test_throws(
        "ArgumentError: all relations must be in the set of component types",
        new_entity!(world, (Position(0, 0),); relations=(ChildOf => parent1,))
    )
    @test_throws(
        "ArgumentError: component Position is not a relationship",
        new_entity!(world, (Position(0, 0),); relations=(Position => parent1,))
    )
    @test_throws(
        "ArgumentError: duplicate component types: ChildOf",
        new_entity!(world, (ChildOf(),); relations=(ChildOf => parent1, ChildOf => parent2))
    )
    @test_throws(
        "ArgumentError: can't use a dead entity as relation target, except for the zero entity",
        new_entity!(world, (Position(0, 0), ChildOf()); relations=(ChildOf => dead_parent,)),
    )
end

@testset "World get/set relations" begin
    world = World(
        Dummy,
        Position,
        ChildOf,
        ChildOf2,
    )

    parent1 = new_entity!(world, ())
    parent2 = new_entity!(world, ())
    dead_parent = new_entity!(world, ())
    remove_entity!(world, dead_parent)

    entity1 = new_entity!(world, (Position(0, 0), ChildOf()); relations=(ChildOf => parent1,))
    entity2 = new_entity!(world, (Position(0, 0), ChildOf()); relations=(ChildOf => parent1,))
    entity3 = new_entity!(world,
        (Position(0, 0), ChildOf2(), ChildOf());
        relations=(ChildOf => parent2, ChildOf2 => parent1),
    )

    parents = get_relations(world, entity1, (ChildOf,))
    @test parents == (parent1,)

    parents = get_relations(world, entity3, (ChildOf,))
    @test parents == (parent2,)

    parents = get_relations(world, entity3, (ChildOf2,))
    @test parents == (parent1,)

    parents = get_relations(world, entity3, (ChildOf, ChildOf2))
    @test parents == (parent2, parent1)

    set_relations!(world, entity1, (ChildOf => parent2,))
    parents = get_relations(world, entity1, (ChildOf,))
    @test parents == (parent2,)

    parents = get_relations(world, entity2, (ChildOf,))
    @test parents == (parent1,)

    @test_throws(
        "ArgumentError: duplicate component types: ChildOf",
        get_relations(world, entity1, (ChildOf, ChildOf)),
    )
    @test_throws(
        "ArgumentError: component Position is not a relationship",
        get_relations(world, entity1, (Position,)),
    )
    @test_throws(
        "ArgumentError: entity does not have the requested relationship component",
        get_relations(world, entity1, (ChildOf2,)),
    )
    @test_throws(
        "ArgumentError: can't get relations of a dead entity",
        get_relations(world, zero_entity, (ChildOf,)),
    )

    @test_throws(
        "ArgumentError: duplicate component types: ChildOf",
        set_relations!(world, entity1, (ChildOf => parent1, ChildOf => parent1)),
    )
    @test_throws(
        "ArgumentError: component Position is not a relationship",
        set_relations!(world, entity1, (Position => parent1,)),
    )
    @test_throws(
        "ArgumentError: entity does not have the requested relationship component",
        set_relations!(world, entity1, (ChildOf2 => parent1,)),
    )
    @test_throws(
        "ArgumentError: can't set relation targets of a dead entity",
        set_relations!(world, zero_entity, (ChildOf => parent1,)),
    )
    @test_throws(
        "ArgumentError: can't use a dead entity as relation target, except for the zero entity",
        set_relations!(world, entity1, (ChildOf => dead_parent,)),
    )
end

@testset "World copy_entity!" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
    )

    counter = 0
    observe!(world, OnCreateEntity; with=(Position,)) do entity
        @test entity._id == counter + 2
        counter += 1
    end

    entity = new_entity!(world, (Position(1, 2), Velocity(3, 4)))
    entity2 = copy_entity!(world, entity)
    @test counter == 2

    @test entity2._id == entity._id + 1
    @test entity2._id == 3
    @test world._tables[2].entities == [entity, entity2]
    @test length(world._storages[offset_ID+2].data[2]) == 2
    @test length(world._storages[offset_ID+3].data[2]) == 2

    pos, vel = get_components(world, entity2, (Position, Velocity))
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)

    @test_throws "can't copy a dead entity" copy_entity!(world, zero_entity)
end

@testset "World copy_entity! with exchange" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
        Altitude,
    )

    counter = 0
    observe!(world, OnCreateEntity; with=(Altitude,)) do entity
        @test entity._id == 3
        counter += 1
    end

    entity = new_entity!(world, (Position(1, 2), Velocity(3, 4)))
    entity2 = copy_entity!(world, entity; add=(Altitude(5),), remove=(Position,))
    @test counter == 1

    @test entity2._id == entity._id + 1
    @test has_components(world, entity2, (Position,)) == false

    vel, alt = get_components(world, entity2, (Velocity, Altitude))
    @test vel == Velocity(3, 4)
    @test alt == Altitude(5)
end

@testset "World copy_entity! copy modes" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
        NoIsBits,
        MutableComponent,
        MutableNoIsBits;
        allow_mutable=true,
    )

    e1 = new_entity!(
        world,
        (
            Position(0, 0),
            Velocity(0, 0),
            NoIsBits([]),
            MutableComponent(1),
            MutableNoIsBits([MutableComponent(1)]),
        ),
    )
    mut1, mut_ni1 = get_components(world, e1, (MutableComponent, MutableNoIsBits))

    e2 = copy_entity!(world, e1)
    mut2, mut_ni2 = get_components(world, e2, (MutableComponent, MutableNoIsBits))
    @test mut1 !== mut2
    @test mut_ni1 !== mut_ni2
    @test mut_ni1.v[1] === mut_ni2.v[1]

    e2 = copy_entity!(world, e1; mode=:ref)
    mut2, mut_ni2 = get_components(world, e2, (MutableComponent, MutableNoIsBits))
    @test mut1 === mut2
    @test mut_ni1 === mut_ni2
    @test mut_ni1.v[1] === mut_ni2.v[1]

    e2 = copy_entity!(world, e1; mode=:copy)
    mut2, mut_ni2 = get_components(world, e2, (MutableComponent, MutableNoIsBits))
    @test mut1 !== mut2
    @test mut_ni1 !== mut_ni2
    @test mut_ni1.v[1] === mut_ni2.v[1]

    e2 = copy_entity!(world, e1; mode=:deepcopy)
    mut2, mut_ni2 = get_components(world, e2, (MutableComponent, MutableNoIsBits))
    @test mut1 !== mut2
    @test mut_ni1 !== mut_ni2
    @test mut_ni1.v[1] !== mut_ni2.v[1]

    @test_throws(
        "ArgumentError: :foobar is not a valid copy mode, must be :ref, :copy or :deepcopy",
        copy_entity!(world, e1; mode=:foobar)
    )
end

@testset "World new_entities! with types" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
        Altitude,
    )

    new_entity!(world, (Position(1, 1), Velocity(3, 4)))
    e = new_entity!(world, (Position(1, 1), Velocity(3, 4)))
    remove_entity!(world, e)

    cnt = 0
    batch = new_entities!(world, 100, (Position, Velocity))
    @test length(batch) == 1
    @test count_entities(batch) == 100
    for (ent, pos_col, vel_col) in batch
        @test length(ent) == 100
        @test length(pos_col) == 100
        @test length(vel_col) == 100
        for i in eachindex(ent)
            @test is_alive(world, ent[i]) == true
            pos_col[i] = Position(i + 1, i + 1)
            vel_col[i] = Velocity(i + 1, i + 1)
            cnt += 1
        end
        @test is_locked(world) == true
    end
    @test cnt == 100
    @test is_locked(world) == false
    @test length(world._tables[2].entities) == 101
    @test length(world._storages[offset_ID+2].data[2]) == 101
    @test length(world._storages[offset_ID+3].data[2]) == 101

    cnt = 0
    for (ent, pos_col, vel_col) in Query(world, (Position, Velocity))
        for i in eachindex(ent)
            @test is_alive(world, ent[i]) == true
            @test pos_col[i] == Position(i, i)
            cnt += 1
        end
    end
    @test cnt == 101
end

@testset "World new_entities! with values" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
        Altitude,
    )

    new_entity!(world, (Position(1, 1), Velocity(3, 4)))
    e = new_entity!(world, (Position(1, 1), Velocity(3, 4)))
    remove_entity!(world, e)

    count = 0
    for (ent, pos_col, vel_col) in new_entities!(world, 100, (Position(99, 99), Velocity(99, 99)); iterate=true)
        @test length(ent) == 100
        @test length(pos_col) == 100
        @test length(vel_col) == 100
        @test pos_col isa FieldViewable
        @test vel_col isa StructArrayView
        for i in eachindex(ent)
            @test is_alive(world, ent[i]) == true
            @test pos_col[i] == Position(99, 99)
            @test vel_col[i] == Velocity(99, 99)
            pos_col[i] = Position(i + 1, i + 1)
            vel_col[i] = Velocity(i + 1, i + 1)
            count += 1
        end
        @test is_locked(world) == true
    end
    @test count == 100
    @test is_locked(world) == false
    @test length(world._tables[2].entities) == 101
    @test length(world._storages[offset_ID+2].data[2]) == 101
    @test length(world._storages[offset_ID+3].data[2]) == 101

    count = 0
    for (ent, pos_col, vel_col) in Query(world, (Position, Velocity))
        for i in eachindex(ent)
            @test is_alive(world, ent[i]) == true
            @test pos_col[i] == Position(i, i)
            count += 1
        end
    end
    @test count == 101

    batch = new_entities!(world, 100, (Position(13, 13), Velocity(13, 13)))
    @test batch === nothing
    @test is_locked(world) == false

    count = 0
    for (ent, pos_col, vel_col) in Query(world, (Position, Velocity))
        for i in eachindex(ent)
            @test is_alive(world, ent[i]) == true
            if i <= 101
                @test pos_col[i] == Position(i, i)
            else
                @test pos_col[i] == Position(13, 13)
            end
            count += 1
        end
    end
    @test count == 201

    for (ent,) in new_entities!(world, 100, (); iterate=true)
        @test length(ent) == 100
    end
end

@static if "CI" in keys(ENV) && VERSION >= v"1.12.0"
    @testset "World new_entities! JET" begin
        world = World(
            Position,
            Velocity => StructArrayStorage,
        )
        using FunctionWrappers
        excluded = Set([
            FunctionWrappers.gen_fptr,
            Base.unsafe_convert,
            Base.setproperty!,
        ])
        function_filter(@nospecialize f) = !(f in excluded)

        #@test_opt function_filter = function_filter new_entities!(world, 100, (Position, Velocity))
        @test_opt function_filter = function_filter new_entities!(world, 100, (Position(13, 13), Velocity(13, 13)))
    end
end

@testset "World add/remove components" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
        Altitude,
        Health,
    )

    e1 = new_entity!(world, ())
    add_components!(world, e1, (Position(1, 2), Velocity(3, 4)))

    e2 = new_entity!(world, (Position(5, 6), Velocity(7, 8)))

    add_components!(world, e1, (Altitude(1), Health(2)))
    add_components!(world, e2, (Altitude(3), Health(4)))

    pos, vel, a, h = get_components(world, e1, (Position, Velocity, Altitude, Health))
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)
    @test a == Altitude(1)
    @test h == Health(2)

    @test has_components(world, e1, (Position, Velocity)) == true

    pos, vel, a, h = get_components(world, e2, (Position, Velocity, Altitude, Health))
    @test pos == Position(5, 6)
    @test vel == Velocity(7, 8)
    @test a == Altitude(3)
    @test h == Health(4)

    remove_components!(world, e1, (Position, Velocity))
    @test has_components(world, e1, (Position, Velocity)) == false

    @test_throws("ArgumentError: can't set components of a dead entity",
        set_components!(world, zero_entity, (Position(1, 2), Velocity(3, 4))))
    @test_throws("ArgumentError: can't add components to a dead entity",
        add_components!(world, zero_entity, (Position(1, 2), Velocity(3, 4))))
    @test_throws("ArgumentError: can't remove components from a dead entity",
        remove_components!(world, zero_entity, (Position, Velocity)))
    @test_throws("ArgumentError: can't check components of a dead entity",
        has_components(world, zero_entity, (Position, Velocity)))
end

@static if "CI" in keys(ENV) && VERSION >= v"1.12.0"
    @testset "World add/remove component JET" begin
        world = World(
            Dummy,
            Position,
            Velocity => StructArrayStorage,
        )
        using FunctionWrappers
        excluded = Set([
            FunctionWrappers.gen_fptr,
            Base.unsafe_convert,
            Base.setproperty!,
        ])
        function_filter(@nospecialize f) = !(f in excluded)

        e1 = new_entity!(world, ())
        @test_opt function_filter = function_filter add_components!(world, e1, (Position(1, 2), Velocity(3, 4)))
        #@test_opt function_filter = function_filter has_components(world, e1, (Position, Velocity))
        #@test_opt function_filter = function_filter remove_components!(world, e1, (Position, Velocity))
    end
end

@testset "World exchange components" begin
    world = World(Dummy, Position, Velocity, Altitude, Health)

    e1 = new_entity!(world, (Position(1, 2), Velocity(3, 4)))

    exchange_components!(world, e1; add=(Altitude(1),), remove=(Position,))
    alt, = get_components(world, e1, (Altitude,))
    @test alt == Altitude(1)
    @test has_components(world, e1, (Position,)) == false

    exchange_components!(world, e1; add=(Health(5),))
    h, = get_components(world, e1, (Health,))
    @test h == Health(5)

    exchange_components!(world, e1; remove=(Velocity,))
    @test has_components(world, e1, (Velocity,)) == false

    @test_throws("ArgumentError: can't exchange components on a dead entity",
        exchange_components!(world, zero_entity; add=(Altitude(1),), remove=(Position,)))

    @test_throws("either components to add or to remove must be given for exchange_components!",
        exchange_components!(world, e1))
end

"""
@static if "CI" in keys(ENV) && VERSION >= v"1.12.0"
    @testset "World exchange component JET" begin
        world = World(Dummy, Position, Velocity, Altitude, Health)

        using FunctionWrappers
        excluded = Set([
            FunctionWrappers.gen_fptr,
            Base.unsafe_convert,
            Base.setproperty!,
        ])
        function_filter(@nospecialize f) = !(f in excluded)

        ex = (e::Entity) -> exchange_components!(world, e; add=(Altitude(1),), remove=(Position,))

        e1 = new_entity!(world, (Position(1, 2), Velocity(3, 4)))
        @test_opt function_filter = function_filter ex(e1)
    end
end
"""

@testset "remove_entity! Tests" begin
    world = World(Dummy, Position, Velocity)

    e1 = new_entity!(world, (Position(1, 1), Velocity(1, 1)))
    e2 = new_entity!(world, (Position(2, 2), Velocity(1, 1)))
    e3 = new_entity!(world, (Position(3, 3), Velocity(1, 1)))

    remove_entity!(world, e2)
    @test is_alive(world, e1) == true
    @test is_alive(world, e2) == false
    @test is_alive(world, e1) == true

    pos, = get_components(world, e1, (Position,))
    @test pos == Position(1, 1)

    pos, = get_components(world, e3, (Position,))
    @test pos == Position(3, 3)

    @test_throws("ArgumentError: can't remove a dead entity",
        remove_entity!(world, zero_entity))
end

@testset "World reset!" begin
    world = World(Dummy, Position, Velocity)

    obs = observe!(world, OnAddComponents, (Position,)) do _
    end

    new_entity!(world, (Position(1, 1),))
    new_entity!(world, (Velocity(1, 1),))
    new_entity!(world, (Position(1, 1), Velocity(1, 1)))

    reset!(world)

    @test length(world._entities) == 1
    @test length(world._entity_pool.entities) == 1
    @test length(world._tables[2].entities) == 0
    @test length(world._tables[3].entities) == 0
    @test length(world._tables[4].entities) == 0
    @test length(world._storages[offset_ID+2].data[2]) == 0
    @test length(world._storages[offset_ID+2].data[3]) == 0
    @test length(world._storages[offset_ID+2].data[4]) == 0
    @test length(world._storages[offset_ID+3].data[2]) == 0
    @test length(world._storages[offset_ID+3].data[3]) == 0
    @test length(world._storages[offset_ID+3].data[4]) == 0

    @test obs._id.id == 0
    @test !_has_observers(world._event_manager, OnAddComponents)

    e = new_entity!(world, (Position(1, 1),))
    @test e._id == 2
    @test e._gen == 0

    q = Query(world, ())
    @test_throws(
        "InvalidStateException: cannot modify a locked world: " *
        "collect entities into a vector and apply changes after query iteration has completed",
        reset!(world))

    close!(q)
    reset!(world)
end

@testset "World relations index" begin
    world = World(Dummy, ChildOf, Position, Velocity, ChildOf2)

    # TODO: re-activate
    """
    new_entity!(world, (Position(0, 0), Velocity(0, 0), ChildOf()))
    new_entity!(world, (Position(0, 0), ChildOf2(), ChildOf()))

    pos_relations = _get_relations(world, Position)
    child_relations = _get_relations(world, ChildOf)
    child2_relations = _get_relations(world, ChildOf2)

    @test length(pos_relations.indices) == 0
    @test length(child_relations.indices) == 3
    @test child_relations.indices[1] == 0
    @test child_relations.indices[2] == 1
    @test child_relations.indices[3] == 1

    @test length(child2_relations.indices) == 3
    @test child2_relations.indices[1] == 0
    @test child2_relations.indices[2] == 0
    @test child2_relations.indices[3] == 2

    @test world._archetypes[1].relations == []
    @test world._archetypes[2].relations == [2 + offset_ID]
    @test world._archetypes[3].relations == [2 + offset_ID, 5 + offset_ID]
    """
end

@testset "World add/remove resources Tests" begin
    world = World(Dummy, Position, Velocity)

    @test has_resource(world, Tick) == false

    add_resource!(world, Tick(0))
    @test has_resource(world, Tick) == true
    res = get_resource(world, Tick)
    @test res isa Tick && res.time == 0
    @test_throws "ArgumentError: World already contains a resource of type Tick" add_resource!(world, Tick(1))
    @inferred Tick get_resource(world, Tick)

    set_resource!(world, Tick(2))
    res = get_resource(world, Tick)
    @test res isa Tick && res.time == 2

    remove_resource!(world, Tick)
    @test has_resource(world, Tick) == false
    @test_throws "KeyError: key Tick not found" get_resource(world, Tick)

    @test_throws "ArgumentError: World does not contain a resource of type Tick" set_resource!(world, Tick(2))
end

@static if "CI" in keys(ENV) && VERSION >= v"1.12.0"
    @testset "Resources JET" begin
        world = World()

        f = () -> begin
            _ = has_resource(world, Tick)
            add_resource!(world, Tick(0))
            _ = has_resource(world, Tick)
            _ = get_resource(world, Tick)
            set_resource!(world, Tick(2))
            remove_resource!(world, Tick)
        end

        @test_opt f()
    end
end
