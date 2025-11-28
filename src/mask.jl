
struct _Not end

struct _Mask{M,B}
    bits::B
    _Mask{M}(bits::B) where {M,B} = new{M,B}(bits)
end

function _Mask{M}() where M
    return _Mask{M}(ntuple(_ -> UInt64(0), M))
end

function _Mask{1}(bits::Int...)
    chunk = UInt64(0)
    for b in bits
        @check 1 ≤ b ≤ 64
        offset = (b - 1) % UInt64
        chunk |= (UInt64(1) << offset)
    end
    return _Mask{1}(chunk)
end

function _Mask{M}(bits::Int...) where {M}
    chunks = ntuple(_ -> UInt64(0), M)
    for b in bits
        @check 1 ≤ b ≤ M * 64
        chunk = (b - 1) >>> 6
        offset = ((b - 1) & UInt64(0x3F)) % UInt64
        chunks = Base.setindex(chunks, chunks[chunk+1] | (UInt64(1) << offset), chunk + 1)
    end
    return _Mask{M}(chunks)
end

function _Mask{M}(::_Not) where M
    return _Mask{M}(ntuple(_ -> typemax(UInt64), M))
end

function _Mask{1}(::_Not, bits::Int...)
    chunk = typemax(UInt64)
    for b in bits
        @check 1 ≤ b ≤ 64
        offset = (b - 1) % UInt64
        chunk &= ~(UInt64(1) << offset)
    end
    return _Mask{1}(chunk)
end

function _Mask{M}(::_Not, bits::Int...) where {M}
    chunks = ntuple(_ -> typemax(UInt64), M)  # 0xFFFFFFFFFFFFFFFF
    for b in bits
        @check 1 ≤ b ≤ M * 64
        chunk = (b - 1) >>> 6
        offset = ((b - 1) & UInt64(0x3F)) % UInt64
        mask = ~(UInt64(1) << offset)
        chunks = Base.setindex(chunks, chunks[chunk+1] & mask, chunk + 1)
    end
    return _Mask{M}(chunks)
end

@generated function _contains_all(mask1::_Mask{M}, mask2::_Mask{M})::Bool where M
    expr = Expr[]
    for i in 1:M
        push!(expr, :(((mask1.bits[$i] & mask2.bits[$i]) == mask2.bits[$i])))
    end
    return Expr(:call, :*, expr...)
end

@generated function _contains_any(mask1::_Mask{M}, mask2::_Mask{M})::Bool where M
    expr = Expr[]
    for i in 1:M
        push!(expr, :(((mask1.bits[$i] & mask2.bits[$i]) == 0)))
    end
    expr_call = Expr(:call, :*, expr...)
    return :(!(($expr_call)))
end

@generated function _and(a::_Mask{M}, b::_Mask{M})::_Mask{M} where M
    expr = Expr[]
    for i in 1:M
        push!(expr, :(a.bits[$i] & b.bits[$i]))
    end
    return :(_Mask{$M}(($(expr...),)))
end

@generated function _or(a::_Mask{M}, b::_Mask{M})::_Mask{M} where M
    expr = Expr[]
    for i in 1:M
        push!(expr, :(a.bits[$i] | b.bits[$i]))
    end
    return :(_Mask{$M}(($(expr...),)))
end

@inline @generated function _clear_bits(a::_Mask{M}, b::_Mask{M})::_Mask{M} where M
    expr = Expr[]
    for i in 1:M
        push!(expr, :(a.bits[$i] & ~b.bits[$i]))
    end
    return :(_Mask{$M}(($(expr...),)))
end

@inline @generated function _is_zero(m::_Mask{M})::Bool where M
    expr = Expr[]
    for i in 1:M
        push!(expr, :((m.bits[$i] == 0)))
    end
    return Expr(:call, :*, expr...)
end

_is_not_zero(m::_Mask)::Bool = !_is_zero(m)

function _active_bit_indices(mask::_Mask{M})::Vector{Int} where M
    indices = Int[]
    for chunk_index in 1:M
        chunk = mask.bits[chunk_index]
        base = (chunk_index - 1) * 64
        while chunk != 0
            tz = trailing_zeros(chunk)
            push!(indices, base + tz + 1)
            chunk &= chunk - UInt64(1) # clear lowest set bit
        end
    end
    return indices
end

mutable struct Bit
    b::UInt64
end

Base.getindex(bits::Bit, x::Int) = getfield(bits, :b)
Base.setindex!(bits::Bit, value::UInt64, x::Int) = setfield!(bits, :b, value)

struct _MutableMask{M,B}
    bits::B
    _MutableMask{M}(bits::B) where {M,B} = new{M,B}(bits)
end

function _MutableMask{1}()
    return _MutableMask{1}(Bit(UInt64(0)))
end

function _MutableMask{M}() where M
    return _MutableMask{M}(zeros(MVector{M,UInt64}))
end

function _MutableMask{1}(mask::_Mask{1})
    return _MutableMask{1}(Bit(mask.bits))
end

function _MutableMask(mask::_Mask{M}) where M
    return _MutableMask{M}(MVector{M,UInt64}(mask.bits))
end

function _set_mask!(mask::_MutableMask{1}, other::_Mask{1})
    mask.bits.b = other.bits
    return mask
end

function _set_mask!(mask::_MutableMask, other::_Mask)
    mask.bits.data = other.bits
    return mask
end

@generated function _equals(mask1::_MutableMask{M}, mask2::_Mask{M})::Bool where M
    expr = Expr[]
    for i in 1:M
        push!(expr, :((mask1.bits[$i] == mask2.bits[$i])))
    end
    return Expr(:call, :*, expr...)
end

function _Mask(mask::_MutableMask{1})
    return _Mask{1}(mask.bits.b)
end

function _Mask(mask::_MutableMask{M}) where M
    return _Mask{M}(Tuple(mask.bits))
end

@inline function _set_bit!(mask::_MutableMask{1}, i::Int)
    offset = (i - 1) % UInt64
    val = UInt64(1) << offset
    mask.bits[1] |= val
end
@inline function _set_bit!(mask::_MutableMask, i::Int)
    chunk = (i - 1) >>> 6
    offset = ((i - 1) % UInt64) & UInt64(0x3F)
    val = UInt64(1) << offset
    mask.bits[chunk+1] |= val
end

@inline function _clear_bit!(mask::_MutableMask{1}, i::Int)
    offset = (i - 1) % UInt64
    val = ~(UInt64(1) << offset)
    mask.bits[1] &= val
end
@inline function _clear_bit!(mask::_MutableMask, i::Int)
    chunk = (i - 1) >>> 6
    offset = ((i - 1) % UInt64) & UInt64(0x3F)
    val = ~(UInt64(1) << offset)
    mask.bits[chunk+1] &= val
end

@inline function _get_bit(mask::Union{_Mask{1},_MutableMask{1}}, i::Int)::Bool
    offset = (i - 1) % UInt64 # which bit within that UInt64
    return ((mask.bits[1] >> offset) & UInt64(1)) % Bool
end
@inline function _get_bit(mask::Union{_Mask,_MutableMask}, i::Int)::Bool
    chunk = (i - 1) >>> 6 # which UInt64 (0-based)
    offset = ((i - 1) % UInt64) & UInt64(0x3F) # which bit within that UInt64
    return ((mask.bits[chunk+1] >> offset) & UInt64(1)) % Bool
end
