using Ark
using Test

@testset "_Mask functionality" begin
    # Test constructor and bit setting
    m1 = _Mask(UInt8(1))
    m1 = _Mask(1, 64, 65, 128, 129, 192, 193)
    @test _get_bit(m1, UInt8(1)) == true
    @test _get_bit(m1, UInt8(64)) == true
    @test _get_bit(m1, UInt8(65)) == true
    @test _get_bit(m1, UInt8(128)) == true
    @test _get_bit(m1, UInt8(129)) == true
    @test _get_bit(m1, UInt8(192)) == true
    @test _get_bit(m1, UInt8(193)) == true

    # Test unset bits
    @test _get_bit(m1, UInt8(2)) == false
    @test _get_bit(m1, UInt8(66)) == false
    @test _get_bit(m1, UInt8(255)) == false

    # Test _contains_all
    m2 = _Mask(64, 128, 193)
    @test _contains_all(m1, m2) == true
    @test _contains_all(m2, m1) == false

    # Test _contains_any
    m3 = _Mask(2, 3, 4)
    @test _contains_any(m1, m2) == true
    @test _contains_any(m1, m3) == false
    @test _contains_any(m2, m3) == false
end
