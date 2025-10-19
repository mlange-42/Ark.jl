using Ark
using Test

include("../src/archetype.jl")

@testset "_Archetype constructor" begin
    # Create an archetype with specific components
    arch = _Archetype(UInt8(1), UInt8(64), UInt8(128), UInt8(255))

    # Check that component indices are stored correctly
    @test arch.component_indices == [UInt8(1), UInt8(64), UInt8(128), UInt8(255)]
    @test len(arch.entities) == 0

    # Check that the mask has the correct bits set
    @test get_bit(arch.mask, UInt8(1)) == true
    @test get_bit(arch.mask, UInt8(64)) == true
    @test get_bit(arch.mask, UInt8(128)) == true
    @test get_bit(arch.mask, UInt8(255)) == true

    # Check that unrelated bits are not set
    @test get_bit(arch.mask, UInt8(2)) == false
    @test get_bit(arch.mask, UInt8(129)) == false
end
