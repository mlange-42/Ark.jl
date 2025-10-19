using Ark
using Test

include("../src/mask.jl")

@testset "_Mask functionality" begin
    # Test constructor and bit setting
    m1 = _Mask(1, 64, 65, 128, 129, 192, 193)
    @test get_bit(m1, UInt8(1)) == true
    @test get_bit(m1, UInt8(64)) == true
    @test get_bit(m1, UInt8(65)) == true
    @test get_bit(m1, UInt8(128)) == true
    @test get_bit(m1, UInt8(129)) == true
    @test get_bit(m1, UInt8(192)) == true
    @test get_bit(m1, UInt8(193)) == true

    # Test unset bits
    @test get_bit(m1, UInt8(2)) == false
    @test get_bit(m1, UInt8(66)) == false
    @test get_bit(m1, UInt8(255)) == false

    # Test contains_all
    m2 = _Mask(64, 128, 256)
    @test contains_all(m1, m2) == true
    @test contains_all(m2, m1) == false

    # Test contains_any
    m3 = _Mask(2, 3, 4)
    @test contains_any(m1, m2) == true
    @test contains_any(m1, m3) == false
    @test contains_any(m2, m3) == false
end
