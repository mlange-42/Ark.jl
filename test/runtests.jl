using Ark
using Test

include("../src/Ark.jl")
include("../src/registry.jl")

@testset "World creation" begin
    world = Ark.World()
    @test isa(world, Ark.World)
    @test isa(world.registry, Ark.ComponentRegistry)
    @test world.storages == Vector{Any}()
    @test world.archetypes == Vector{Ark.Archetype}()
end

@testset "ComponentRegistry Tests" begin
    registry = ComponentRegistry()

    # Register new types
    id_int = component_id!(registry, Int)
    id_float = component_id!(registry, Float64)
    id_string = component_id!(registry, String)

    # Check that IDs are UInt8 and unique
    @test isa(id_int, UInt8)
    @test isa(id_float, UInt8)
    @test isa(id_string, UInt8)
    @test id_int != id_float != id_string

    # Check repeated registration returns same ID
    @test component_id!(registry, Int) == id_int
end
