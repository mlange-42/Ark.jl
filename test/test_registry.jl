using Ark
using Test

include("TestTypes.jl")
include("../src/registry.jl")

using .TestTypes: Position

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
