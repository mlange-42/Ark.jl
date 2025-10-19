using Ark
using Test

include("TestTypes.jl")
include("../src/Ark.jl")

using .TestTypes: Position

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
