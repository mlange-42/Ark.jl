using Ark
using Test

include("../src/Ark.jl")
include("../src/registry.jl")

struct Position
    x::Float64
    y::Float64
end

@testset "World creation" begin
    world = Ark.World()
    @test isa(world, Ark.World)
    @test isa(world.registry, Ark._ComponentRegistry)
    @test world.storages == Vector{Any}()
    @test world.archetypes == Vector{Ark._Archetype}()
end

@testset "World Component Registration" begin
    world = Ark.World()

    # Register Int component
    id_int = Ark._component_id!(world, Int)
    @test isa(id_int, UInt8)
    @test length(world.storages) == 1
    @test world.storages[id_int + 1] isa Ark._ComponentStorage{Int}

    # Register Position component
    id_pos = Ark._component_id!(world, Position)
    @test isa(id_pos, UInt8)
    @test length(world.storages) == 2
    @test world.storages[id_pos + 1] isa Ark._ComponentStorage{Position}

    # Re-register Int component (should not add new storage)
    id_int2 = Ark._component_id!(world, Int)
    @test id_int2 == id_int
    @test length(world.storages) == 2
end

@testset "ComponentRegistry Tests" begin
    registry = _ComponentRegistry()

    # Register new types
    id_int = _component_id!(registry, Int)
    id_float = _component_id!(registry, Float64)
    id_pos = _component_id!(registry, Position)

    # Check that IDs are UInt8 and unique
    @test isa(id_int, UInt8)
    @test isa(id_float, UInt8)
    @test isa(id_pos, UInt8)
    @test id_int != id_float != id_pos

    # Check repeated registration returns same ID
    @test _component_id!(registry, Int) == id_int
end
