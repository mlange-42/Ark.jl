using Ark
using Test

using .TestTypes: Position, Velocity

@testset "World creation" begin
    world = Ark.World()
    @test isa(world, Ark.World)
    @test isa(world._registry, Ark._ComponentRegistry)
    @test world._storages == Vector{Any}()
    @test length(world._archetypes) == 1
end

@testset "World Component Registration" begin
    world = Ark.World()

    # Register Int component
    id_int = Ark._component_id!(world, Int)
    @test isa(id_int, UInt8)
    @test world._registry.types[id_int] == Int
    @test length(world._storages) == 1
    @test world._storages[id_int] isa Ark._ComponentStorage{Int}
    @test length(world._storages[id_int].data) == 1

    # Register Position component
    id_pos = Ark._component_id!(world, Position)
    @test isa(id_pos, UInt8)
    @test world._registry.types[id_pos] == Position
    @test length(world._storages) == 2
    @test world._storages[id_pos] isa Ark._ComponentStorage{Position}
    @test length(world._storages[id_pos].data) == 1

    # Re-register Int component (should not add new storage)
    id_int2 = Ark._component_id!(world, Int)
    @test id_int2 == id_int
    @test length(world._storages) == 2
end

@testset "_get_storage Tests" begin
    world = Ark.World()

    # Retrieve storage using type-only version
    storage1 = Ark._get_storage(world, Int)
    @test storage1 isa Ark._ComponentStorage{Int}

    # Retrieve storage using type + id version
    id = Ark._component_id!(world, Int)
    storage2 = Ark._get_storage(world, id, Int)
    @test storage2 isa Ark._ComponentStorage{Int}

    # Both retrievals should return the same object
    @test storage1 === storage2

end

@testset "_find_or_create_archetype! Tests" begin
    world = World()

    pos_id = _component_id!(world, Position)
    @test pos_id == UInt8(1)

    index = _find_or_create_archetype!(world, pos_id)
    @test index == 2
    @test length(world._archetypes) == 2

    vel_id = _component_id!(world, Velocity)
    @test vel_id == UInt8(2)

    index = _find_or_create_archetype!(world, pos_id, vel_id)
    @test index == 3
    @test length(world._archetypes) == 3

    index = _find_or_create_archetype!(world, pos_id, vel_id)
    @test index == 3

    @test world._archetypes[2].components == [pos_id]
    @test world._archetypes[3].components == [pos_id, vel_id]

    @test length(world._storages) == 2
    @test length(world._registry.types) == 2

    pos_storage = _get_storage(world, pos_id, Position)
    vel_storage = _get_storage(world, vel_id, Velocity)

    @test isa(pos_storage, _ComponentStorage{Position})
    @test isa(vel_storage, _ComponentStorage{Velocity})
    @test length(pos_storage.data) == 3
    @test length(vel_storage.data) == 3
    @test pos_storage.data[1] == nothing
    @test vel_storage.data[1] == nothing
    @test pos_storage.data[2] == Vector{Position}()
    @test vel_storage.data[2] == nothing
    @test pos_storage.data[3] == Vector{Position}()
    @test vel_storage.data[3] == Vector{Velocity}()
end

@testset "_create_entity! Tests" begin
    world = World()
    pos_id = _component_id!(world, Position)
    vel_id = _component_id!(world, Velocity)

    arch_index = _find_or_create_archetype!(world, pos_id, vel_id)
    @test arch_index == 2

    entity, index = _create_entity!(world, arch_index)
    @test entity == _new_entity(1, 0)
    @test index == 1
    @test world._entities == [_EntityIndex(arch_index, UInt32(1))]

    pos_storage = _get_storage(world, pos_id, Position)
    vel_storage = _get_storage(world, vel_id, Velocity)

    @test length(pos_storage.data[arch_index]) == 1
    @test length(vel_storage.data[arch_index]) == 1
end