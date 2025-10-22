using Ark
using Test

using .TestTypes: Position, Velocity

@testset "World creation" begin
    world = World()
    @test isa(world, World)
    @test isa(world._registry, _ComponentRegistry)
    @test world._storages == ()
    @test length(world._archetypes) == 1
end

@testset "World creation 2" begin
    world = World(Position, Velocity)
    @test isa(world, World)

    @test _component_id(world, Velocity) == 2
    @test _component_id(world, Position) == 1
    @test_throws ErrorException _component_id(world, Altitude)

    @test isa(_get_storage(world, Position), _ComponentStorage{Position})
    @test isa(_get_storage(world, Val{Position}()), _ComponentStorage{Position})
    @test isa(_get_storage_by_id(world, Val(1)), _ComponentStorage{Position})
end

@testset "World create archetype" begin
    world = World(Position, Velocity)

    arch1 = _find_or_create_archetype!(world, world._graph.nodes[1], (UInt8(1),), ())
    @test arch1 == 2

    arch2 = _find_or_create_archetype!(world, world._graph.nodes[1], (UInt8(1), UInt8(2)), ())
    @test arch2 == 3

    arch3 = _find_or_create_archetype!(world, world._graph.nodes[1], (UInt8(1),), ())
    @test arch3 == arch1

    entity, _ = _create_entity!(world, arch1)
    _move_entity!(world, entity, arch2)
    remove_entity!(world, entity)
end

@testset "World Component Registration" begin
    world = World(Int, Position)

    # Register Int component
    id_int = _component_id(world, Int)
    @test isa(id_int, UInt8)
    @test world._registry.types[id_int] == Int
    @test length(world._storages) == 2
    @test world._storages[id_int] isa _ComponentStorage{Int}
    @test length(world._storages[id_int].data) == 1

    # Register Position component
    id_pos = _component_id(world, Position)
    @test isa(id_pos, UInt8)
    @test world._registry.types[id_pos] == Position
    @test length(world._storages) == 2
    @test world._storages[id_pos] isa _ComponentStorage{Position}
    @test length(world._storages[id_pos].data) == 1

    # Re-register Int component (should not add new storage)
    id_int2 = _component_id(world, Int)
    @test id_int2 == id_int
    @test length(world._storages) == 2

    @test_throws ErrorException _component_id(world, Velocity)
end

@testset "_get_storage Tests" begin
    world = World(Int)

    # Retrieve storage using type-only version
    storage1 = _get_storage(world, Int)
    @test storage1 isa _ComponentStorage{Int}

    # Retrieve storage using type + id version
    id = _component_id(world, Int)
    storage2 = _get_storage(world, Int)
    @test storage2 isa _ComponentStorage{Int}

    # Both retrievals should return the same object
    @test storage1 === storage2

end

@testset "_find_or_create_archetype! Tests" begin
    world = World(Position, Velocity)

    pos_id = _component_id(world, Position)
    @test pos_id == UInt8(1)

    index = _find_or_create_archetype!(world, world._graph.nodes[1], (pos_id,), ())
    @test index == 2
    @test length(world._archetypes) == 2

    vel_id = _component_id(world, Velocity)
    @test vel_id == UInt8(2)

    index = _find_or_create_archetype!(world, world._graph.nodes[1], (pos_id, vel_id), ())
    @test index == 3
    @test length(world._archetypes) == 3

    index = _find_or_create_archetype!(world, world._graph.nodes[1], (pos_id, vel_id), ())
    @test index == 3

    @test world._archetypes[2].components == [pos_id]
    @test world._archetypes[3].components == [pos_id, vel_id]

    @test length(world._storages) == 2
    @test length(world._registry.types) == 2

    pos_storage = _get_storage(world, Position)
    vel_storage = _get_storage(world, Velocity)

    @test isa(pos_storage, _ComponentStorage{Position})
    @test isa(vel_storage, _ComponentStorage{Velocity})
    @test length(pos_storage.data) == 3
    @test length(vel_storage.data) == 3
    @test pos_storage.data[1] == nothing
    @test vel_storage.data[1] == nothing
    @test pos_storage.data[2]._data == Vector{Position}()
    @test vel_storage.data[2] == nothing
    @test pos_storage.data[3]._data == Vector{Position}()
    @test vel_storage.data[3]._data == Vector{Velocity}()
end

@testset "_create_entity! Tests" begin
    world = World(Position, Velocity)
    pos_id = _component_id(world, Position)
    vel_id = _component_id(world, Velocity)

    arch_index = _find_or_create_archetype!(world, world._graph.nodes[1], (pos_id, vel_id), ())
    @test arch_index == 2

    entity, index = _create_entity!(world, arch_index)
    @test entity == _new_entity(2, 0)
    @test index == 1
    @test world._entities == [_EntityIndex(typemax(UInt32), 0), _EntityIndex(arch_index, UInt32(1))]

    pos_storage = _get_storage(world, Position)
    vel_storage = _get_storage(world, Velocity)

    @test length(pos_storage.data[arch_index]) == 1
    @test length(vel_storage.data[arch_index]) == 1
end

@testset "World get/set components" begin
    world = World(Position, Velocity)
    m = Map(world, (Position, Velocity))

    e1 = new_entity!(m, (Position(1, 2), Velocity(3, 4)))
    e2 = new_entity!(world)

    pos, vel = get_components(world, e1, Position, Velocity)
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)

    # TODO: do we want that, or do we want it to return `nothing`?
    @test_throws FieldError get_components(world, e2, Position, Velocity)

    @test_throws ErrorException get_components(world, zero_entity, Position, Velocity)
    @test_throws ErrorException get_components(world, e2, Altitude)

    t = get_components(world, e1)
    @test t == ()

    set_components!(world, e1, Position(5, 6), Velocity(7, 8))
    pos, vel = get_components(world, e1, Position, Velocity)
    @test pos == Position(5, 6)
    @test vel == Velocity(7, 8)
end

@testset "new_entity! Tests" begin
    world = World(Position, Velocity)

    entity = new_entity!(world)
    @test entity == _new_entity(2, 0)
    @test is_alive(world, entity) == true

    entity = new_entity!(world, Position(1, 2), Velocity(3, 4))
    @test entity == _new_entity(3, 0)
    @test is_alive(world, entity) == true

    pos, vel = get_components(world, entity, Position, Velocity)
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)
end

@testset "World add/remove components" begin
    world = World(Position, Velocity, Altitude, Health)

    e1 = new_entity!(world)
    add_components!(world, e1, Position(1, 2), Velocity(3, 4))

    e2 = new_entity!(world, Position(5, 6), Velocity(7, 8))

    add_components!(world, e1, Altitude(1), Health(2))
    add_components!(world, e2, Altitude(3), Health(4))

    pos, vel, a, h = get_components(world, e1, Position, Velocity, Altitude, Health)
    @test pos == Position(1, 2)
    @test vel == Velocity(3, 4)
    @test a == Altitude(1)
    @test h == Health(2)

    @test has_components(world, e1, Position, Velocity) == true

    pos, vel, a, h = get_components(world, e2, Position, Velocity, Altitude, Health)
    @test pos == Position(5, 6)
    @test vel == Velocity(7, 8)
    @test a == Altitude(3)
    @test h == Health(4)

    remove_components!(world, e1, Position, Velocity)
    @test has_components(world, e1, Position, Velocity) == false

    @test_throws ErrorException add_components!(world, zero_entity, Position(1, 2), Velocity(3, 4))
    @test_throws ErrorException remove_components!(world, zero_entity, Position, Velocity)
    @test_throws ErrorException has_components(world, zero_entity, Position, Velocity)
end

@testset "remove_entity! Tests" begin
    world = World(Position, Velocity)
    m = Map(world, (Position, Velocity))

    e1 = new_entity!(m, (Position(1, 1), Velocity(1, 1)))
    e2 = new_entity!(m, (Position(2, 2), Velocity(1, 1)))
    e3 = new_entity!(m, (Position(3, 3), Velocity(1, 1)))

    remove_entity!(world, e2)
    @test is_alive(world, e1) == true
    @test is_alive(world, e2) == false
    @test is_alive(world, e1) == true

    pos, _ = m[e1]
    @test pos == Position(1, 1)

    pos, _ = m[e3]
    @test pos == Position(3, 3)
end
