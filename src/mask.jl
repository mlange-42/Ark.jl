
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

function _contains_all(mask1::_Mask, mask2::_Mask)::Bool
    return ((mask1.bits[1] & mask2.bits[1]) == mask2.bits[1]) *
           ((mask1.bits[2] & mask2.bits[2]) == mask2.bits[2]) *
           ((mask1.bits[3] & mask2.bits[3]) == mask2.bits[3]) *
           ((mask1.bits[4] & mask2.bits[4]) == mask2.bits[4])
end

function _contains_any(mask1::_Mask, mask2::_Mask)::Bool
    return !(((mask1.bits[1] & mask2.bits[1]) == 0) *
             ((mask1.bits[2] & mask2.bits[2]) == 0) *
             ((mask1.bits[3] & mask2.bits[3]) == 0) *
             ((mask1.bits[4] & mask2.bits[4]) == 0))
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

struct _MutableMask
    bits::MVector{4,UInt64}
end

function _MutableMask()
    return _MutableMask(MVector{4,UInt64}(0, 0, 0, 0))
end

function _MutableMask(mask::_Mask)
    return _MutableMask(MVector{4,UInt64}(mask.bits))
end

function _set_mask!(mask::_MutableMask, other::_Mask)
    b = mask.bits
    GC.@preserve b begin
        dst = Base.unsafe_convert(Ptr{MVector{4, UInt64}}, mask.bits)
        unsafe_store!(dst, other.bits)
    end
    return mask
end

function _equals(mask1::_MutableMask, mask2::_Mask)::Bool
    return (mask1.bits[1] == mask2.bits[1]) *
           (mask1.bits[2] == mask2.bits[2]) *
           (mask1.bits[3] == mask2.bits[3]) *
           (mask1.bits[4] == mask2.bits[4])
end

function _Mask(mask::_MutableMask)
    return _Mask(Tuple(mask.bits))
end

@inline function _set_bit!(mask::_MutableMask, i::UInt8)
    chunk = (i - UInt8(1)) >>> 6
    offset = (i - UInt8(1)) & 0x3F
    val = UInt64(1) << (offset % UInt64)
    mask.bits[chunk+1] |= val
end

@inline function _clear_bit!(mask::_MutableMask, i::UInt8)
    chunk = (i - UInt8(1)) >>> 6
    offset = (i - UInt8(1)) & 0x3F
    val = ~(UInt64(1) << (offset % UInt64))
    mask.bits[chunk+1] &= val
end

@inline function _get_bit(mask::Union{_Mask, _MutableMask}, i::UInt8)::Bool
    chunk = (i - UInt8(1)) >>> 6 # which UInt64 (0-based)
    offset = (i - UInt8(1)) & 0x3F # which bit within that UInt64
    return (mask.bits[chunk+1] >> (offset % UInt64)) & UInt64(1) == 1
end
