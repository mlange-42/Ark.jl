
struct _Mask
    bits::NTuple{4,UInt64}
end

function _Mask()
    return _Mask(ntuple(_ -> UInt64(0), 4))
end

function _Mask(bits::UInt8...)
    chunks = ntuple(_ -> UInt64(0), 4)

    for b in bits
        @assert b > 0 "Bit index must be between 1 and 256"
        chunk = (b - 1) >>> 6
        offset = (b - 1) & 0x3F
        chunks = Base.setindex(chunks, chunks[chunk+1] | (UInt64(1) << offset), chunk + 1)
    end

    return _Mask(chunks)
end

function _Mask(bits::Integer...)
    chunks = ntuple(_ -> UInt64(0), 4)

    for b in bits
        @assert 1 ≤ b ≤ 256 "Bit index must be between 1 and 256"
        chunk = (b - 1) >>> 6
        offset = (b - 1) & 0x3F
        chunks = Base.setindex(chunks, chunks[chunk+1] | (UInt64(1) << offset), chunk + 1)
    end

    return _Mask(chunks)
end

function _get_bit(mask::_Mask, i::UInt8)::Bool
    chunk = (i - 1) >>> 6        # which UInt64 (0-based)
    offset = (i - 1) & 0x3F       # which bit within that UInt64
    return (mask.bits[chunk+1] >> offset) & 0x1 == 1
end

function _contains_all(mask1::_Mask, mask2::_Mask)::Bool
    return (mask1.bits[1] & mask2.bits[1]) == mask2.bits[1] &&
           (mask1.bits[2] & mask2.bits[2]) == mask2.bits[2] &&
           (mask1.bits[3] & mask2.bits[3]) == mask2.bits[3] &&
           (mask1.bits[4] & mask2.bits[4]) == mask2.bits[4]
end

function _contains_any(mask1::_Mask, mask2::_Mask)::Bool
    return (mask1.bits[1] & mask2.bits[1]) != 0 ||
           (mask1.bits[2] & mask2.bits[2]) != 0 ||
           (mask1.bits[3] & mask2.bits[3]) != 0 ||
           (mask1.bits[4] & mask2.bits[4]) != 0
end
