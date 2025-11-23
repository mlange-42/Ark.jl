
@testset "_Mask functionality" begin
    # Test constructor and bit setting
    m1 = _Mask{4}(1)
    m1 = _Mask{4}(1, 64, 65, 128, 129, 192, 193)
    @test _get_bit(m1, 1) == true
    @test _get_bit(m1, 64) == true
    @test _get_bit(m1, 65) == true
    @test _get_bit(m1, 128) == true
    @test _get_bit(m1, 129) == true
    @test _get_bit(m1, 192) == true
    @test _get_bit(m1, 193) == true

    # Test unset bits
    @test _get_bit(m1, 2) == false
    @test _get_bit(m1, 66) == false
    @test _get_bit(m1, 255) == false

    # Test _contains_all
    m2 = _Mask{4}(64, 128, 193)
    @test _contains_all(m1, m2) == true
    @test _contains_all(m2, m1) == false

    # Test _contains_any
    m3 = _Mask{4}(2, 3, 4)
    @test _contains_any(m1, m2) == true
    @test _contains_any(m1, m3) == false
    @test _contains_any(m2, m3) == false

    m4 = _Mask{4}(_Not(), 1, 5)
    @test _get_bit(m4, 1) == false
    @test _get_bit(m4, 2) == true
    @test _get_bit(m4, 5) == false

    m4 = _Mask{4}(_Not(), 1, 5)
    @test _get_bit(m4, 1) == false
    @test _get_bit(m4, 2) == true
    @test _get_bit(m4, 5) == false
end

@testset "_Mask _is_zero and _is_not_zero" begin
    m1 = _Mask{4}(234)
    @test _is_zero(m1) == false
    @test _is_not_zero(m1) == true

    m2 = _Mask{4}()
    @test _is_zero(m2) == true
    @test _is_not_zero(m2) == false

    m3 = _Mask{4}(_Not())
    @test _is_zero(m3) == false
    @test _is_not_zero(m3) == true
end

@testset "_Mask clear_bits" begin
    m1 = _Mask{4}(1, 64, 65)
    m2 = _Mask{4}(1, 64)

    @test _get_bit(m1, 1) == true
    @test _get_bit(m1, 64) == true
    @test _get_bit(m1, 65) == true

    m3 = _clear_bits(m1, m2)
    @test _get_bit(m3, 1) == false
    @test _get_bit(m3, 64) == false
    @test _get_bit(m3, 65) == true
end

@testset "_Mask bitwise operations" begin
    m1 = _Mask{4}(1, 2, 3)       # bits 1, 2, 3 set
    m2 = _Mask{4}(3, 4, 5)       # bits 3, 4, 5 set

    mand = _and(m1, m2)
    mor = _or(m1, m2)

    # _and should only keep bit 3
    @test _get_bit(mand, 3) == true
    @test _get_bit(mand, 1) == false
    @test _get_bit(mand, 4) == false

    # _or should have bits 1–5
    for i in 1:5
        @test _get_bit(mor, i) == true
    end

    # Check that no extra bits are set
    @test _get_bit(mor, 6) == false
end

@testset "_MutableMask bit operations" begin
    # Create a base _Mask with bits 1, 65, 129, 193 set (one per chunk)
    base = _Mask{4}(1, 65, 129, 193)
    mm = _MutableMask(base)

    # Check initial state matches base mask
    @test _get_bit(mm, 1) == true
    @test _get_bit(mm, 65) == true
    @test _get_bit(mm, 129) == true
    @test _get_bit(mm, 193) == true

    # Check unset bits
    @test _get_bit(mm, 2) == false
    @test _get_bit(mm, 66) == false
    @test _get_bit(mm, 130) == false
    @test _get_bit(mm, 194) == false

    # Set new bits
    _set_bit!(mm, 2)
    _set_bit!(mm, 66)
    _set_bit!(mm, 130)
    _set_bit!(mm, 194)

    @test _get_bit(mm, 2) == true
    @test _get_bit(mm, 66) == true
    @test _get_bit(mm, 130) == true
    @test _get_bit(mm, 194) == true

    # Clear original bits
    _clear_bit!(mm, 1)
    _clear_bit!(mm, 65)
    _clear_bit!(mm, 129)
    _clear_bit!(mm, 193)

    @test _get_bit(mm, 1) == false
    @test _get_bit(mm, 65) == false
    @test _get_bit(mm, 129) == false
    @test _get_bit(mm, 193) == false
end

@testset "_active_bit_indices" begin
    # Test with no bits set
    m0 = _Mask{4}()
    @test _active_bit_indices(m0) == UInt8[]

    # Test with one bit set in each chunk
    m1 = _Mask{4}(1, 65, 129, 193)
    @test sort(_active_bit_indices(m1)) == [1, 65, 129, 193]

    # Test with multiple bits set
    m2 = _Mask{4}(1, 2, 3, 64, 65, 66, 128, 129, 130, 192, 193, 194)
    expected = UInt8[1, 2, 3, 64, 65, 66, 128, 129, 130, 192, 193, 194]
    @test sort(_active_bit_indices(m2)) == expected
end
