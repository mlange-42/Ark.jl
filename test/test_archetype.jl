using Ark
using Test

@testset "_Archetype constructor" begin
    # Create an archetype with specific components
    comps = [UInt8(1), UInt8(64), UInt8(128), UInt8(255)]
    arch = _Archetype(_Mask(comps...), comps...)

    # Check that component indices are stored correctly
    @test arch.components == [UInt8(1), UInt8(64), UInt8(128), UInt8(255)]
    @test length(arch.entities) == 0

    # Check that the mask has the correct bits set
    @test _get_bit(arch.mask, UInt8(1)) == true
    @test _get_bit(arch.mask, UInt8(64)) == true
    @test _get_bit(arch.mask, UInt8(128)) == true
    @test _get_bit(arch.mask, UInt8(255)) == true

    # Check that unrelated bits are not set
    @test _get_bit(arch.mask, UInt8(2)) == false
    @test _get_bit(arch.mask, UInt8(129)) == false
end
