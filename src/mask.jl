
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

function _and(a::_Mask, b::_Mask)::_Mask
    return _Mask((
        a.bits[1] & b.bits[1],
        a.bits[2] & b.bits[2],
        a.bits[3] & b.bits[3],
        a.bits[4] & b.bits[4],
    ))
end

function _or(a::_Mask, b::_Mask)::_Mask
    return _Mask((
        a.bits[1] | b.bits[1],
        a.bits[2] | b.bits[2],
        a.bits[3] | b.bits[3],
        a.bits[4] | b.bits[4],
    ))
end

@inline function _clear_bits(a::_Mask, b::_Mask)::_Mask
    return _Mask((
        a.bits[1] & ~b.bits[1],
        a.bits[2] & ~b.bits[2],
        a.bits[3] & ~b.bits[3],
        a.bits[4] & ~b.bits[4],
    ))
end

function _active_bit_indices(mask::_Mask)::Vector{UInt8}
    indices = UInt8[]
    for chunk_index in 1:4
        chunk = mask.bits[chunk_index]
        base = UInt8((chunk_index - 1) * 64)
        while chunk != 0
            tz = trailing_zeros(chunk)
            push!(indices, base + UInt8(tz + 1))
            chunk &= chunk - 1  # clear lowest set bit
        end
    end
    return indices
end

mutable struct _MutableMask
    # TODO: can we use something more efficient here that does not use if/else?
    # already tried but slower: NTuple{4, UInt64}, StaticArrays.MVector{4, UInt64} 
    b1::UInt64
    b2::UInt64
    b3::UInt64
    b4::UInt64
end

function _MutableMask()
    return _MutableMask(0, 0, 0, 0)
end

function _MutableMask(mask::_Mask)
    return _MutableMask(mask.bits[1], mask.bits[2], mask.bits[3], mask.bits[4])
end

function _equals(mask1::_MutableMask, mask2::_Mask)::Bool
    return mask1.b1 == mask2.bits[1] &&
           mask1.b2 == mask2.bits[2] &&
           mask1.b3 == mask2.bits[3] &&
           mask1.b4 == mask2.bits[4]
end

function _Mask(mask::_MutableMask)
    return _Mask((mask.b1, mask.b2, mask.b3, mask.b4))
end

@inline function _set_bit!(mask::_MutableMask, i::UInt8)
    chunk = (i - 1) >>> 6
    offset = (i - 1) & 0x3F
    val = UInt64(1) << offset
    if chunk == 0
        mask.b1 |= val
    elseif chunk == 1
        mask.b2 |= val
    elseif chunk == 2
        mask.b3 |= val
    else
        mask.b4 |= val
    end
end

@inline function _clear_bit!(mask::_MutableMask, i::UInt8)
    chunk = (i - 1) >>> 6
    offset = (i - 1) & 0x3F
    val = ~(UInt64(1) << offset)
    if chunk == 0
        mask.b1 &= val
    elseif chunk == 1
        mask.b2 &= val
    elseif chunk == 2
        mask.b3 &= val
    else
        mask.b4 &= val
    end
end

@inline function _get_bit(mask::_MutableMask, i::UInt8)::Bool
    chunk = (i - 1) >>> 6
    offset = (i - 1) & 0x3F
    if chunk == 0
        return (mask.b1 >> offset) & 0x1 == 1
    elseif chunk == 1
        return (mask.b2 >> offset) & 0x1 == 1
    elseif chunk == 2
        return (mask.b3 >> offset) & 0x1 == 1
    else
        return (mask.b4 >> offset) & 0x1 == 1
    end
end
