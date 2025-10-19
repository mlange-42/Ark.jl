using Ark
using Test

include("../src/Ark.jl")

@testset "World creation" begin
    world = Ark.World()
    @test isa(world, Ark.World)
    @test isa(world.registry, Ark.ComponentRegistry)
    @test world.storages == Vector{Any}()
    @test world.archetypes == Vector{Ark.Archetype}()
end
