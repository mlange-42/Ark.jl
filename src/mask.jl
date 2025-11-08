
struct _Not end

struct _Mask{N}
    bits::NTuple{N,UInt64}
end

function _Mask{N}() where N
    return _Mask(ntuple(_ -> UInt64(0), N))
end

function _Mask{N}(bits::UInt8...) where N
    chunks = ntuple(_ -> UInt64(0), N)

    for b in bits
        @check b > 0
        chunk = (b - 1) >>> 6
        offset = (b - 1) & 0x3F
        chunks = Base.setindex(chunks, chunks[chunk+1] | (UInt64(1) << offset), chunk + 1)
    end

    return _Mask(chunks)
end

function _Mask{N}(::_Not, bits::UInt8...) where N
    chunks = ntuple(_ -> typemax(UInt64), N)  # 0xFFFFFFFFFFFFFFFF

    for b in bits
        @check b > 0
        chunk = (b - 1) >>> 6
        offset = (b - 1) & 0x3F
        mask = ~(UInt64(1) << offset)
        chunks = Base.setindex(chunks, chunks[chunk+1] & mask, chunk + 1)
    end

    return _Mask(chunks)
end

function _Mask{N}(bits::Integer...) where N
    chunks = ntuple(_ -> UInt64(0), N)

    for b in bits
        @check 1 ≤ b ≤ 256
        chunk = (b - 1) >>> 6
        offset = (b - 1) & 0x3F
        chunks = Base.setindex(chunks, chunks[chunk+1] | (UInt64(1) << offset), chunk + 1)
    end

    return _Mask(chunks)
end

function _Mask{N}(::_Not, bits::Integer...) where N
    chunks = ntuple(_ -> typemax(UInt64), N)  # 0xFFFFFFFFFFFFFFFF

    for b in bits
        @check 1 ≤ b ≤ 256
        chunk = (b - 1) >>> 6
        offset = (b - 1) & 0x3F
        mask = ~(UInt64(1) << offset)
        chunks = Base.setindex(chunks, chunks[chunk+1] & mask, chunk + 1)
    end

    return _Mask(chunks)
end

@generated function _contains_all(mask1::_Mask{N}, mask2::_Mask{N})::Bool where N
    expr = Expr[]
    for i in 1:N
        push!(expr, :(((mask1.bits[$i] & mask2.bits[$i]) == mask2.bits[$i])))
    end
    return Expr(:call, :*, expr...)
end

@generated function _contains_any(mask1::_Mask{N}, mask2::_Mask{N})::Bool where N
    expr = Expr[]
    for i in 1:N
        push!(expr, :(((mask1.bits[$i] & mask2.bits[$i]) == 0)))
    end
    expr_call = Expr(:call, :*, expr...)
    return :(!(($expr_call)))
end

@generated function _and(a::_Mask{N}, b::_Mask{N})::_Mask{N} where N
    expr = Expr[]
    for i in 1:N
        push!(expr, :(a.bits[$i] & b.bits[$i]))
    end
    return :(_Mask{$N}(($(expr...),)))
end

@generated function _or(a::_Mask{N}, b::_Mask{N})::_Mask{N} where N
    expr = Expr[]
    for i in 1:N
        push!(expr, :(a.bits[$i] | b.bits[$i]))
    end
    return :(_Mask{$N}(($(expr...),)))
end

@inline @generated function _clear_bits(a::_Mask{N}, b::_Mask{N})::_Mask{N} where N
    expr = Expr[]
    for i in 1:N
        push!(expr, :(a.bits[$i] & ~b.bits[$i]))
    end
    return :(_Mask{$N}(($(expr...),)))
end

@inline @generated function _is_zero(m::_Mask{N})::Bool where N
    expr = Expr[]
    for i in 1:N
        push!(expr, :((m.bits[$i] == 0)))
    end
    return Expr(:call, :*, expr...)
end

_is_not_zero(m::_Mask)::Bool = !_is_zero(m)

function _active_bit_indices(mask::_Mask{N})::Vector{UInt8} where N
    indices = UInt8[]
    for chunk_index in 1:N
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

struct _MutableMask{N}
    bits::MVector{N,UInt64}
end

function _MutableMask{N}() where N
    return _MutableMask(zeros(MVector{N, UInt64}))
end

function _MutableMask(mask::_Mask{N}) where N
    return _MutableMask(MVector{N,UInt64}(mask.bits))
end

function _set_mask!(mask::_MutableMask, other::_Mask)
    mask.bits.data = other.bits
    return mask
end

@generated function _equals(mask1::_MutableMask{N}, mask2::_Mask{N})::Bool where N
    expr = Expr[]
    for i in 1:N
        push!(expr, :((mask1.bits[$i] == mask2.bits[$i])))
    end
    return Expr(:call, :*, expr...)
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

@inline function _get_bit(mask::Union{_Mask,_MutableMask}, i::UInt8)::Bool
    chunk = (i - UInt8(1)) >>> 6 # which UInt64 (0-based)
    offset = (i - UInt8(1)) & 0x3F # which bit within that UInt64
    return (mask.bits[chunk+1] >> (offset % UInt64)) & UInt64(1) == 1
end
