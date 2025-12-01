
isdefined(@__MODULE__, :Memory) || const Memory = Vector # Compat for Julia < 1.11

const _LOAD_FACTOR = 0.75
const _RSHIFT = sizeof(UInt) * 7

mutable struct _Mask_Map{N,V}
    keys::Memory{_Mask{N}}
    vals::Memory{V}
    occupied::Memory{UInt8}
    count::Int
    mask::Int
    max_load::Int
    function _Mask_Map{N,V}(initial_size::Int=2) where {N,V}
        # Force power of 2 size
        sz = nextpow(2, initial_size)
        keys = Memory{_Mask{N}}(undef, sz)
        vals = Memory{V}(undef, sz)
        occupied = zeros(UInt8, sz)
        max_load = floor(Int, sz * _LOAD_FACTOR)
        new{N,V}(keys, vals, occupied, 0, sz - 1, max_load)
    end
end

function _grow!(d::_Mask_Map{N,V}) where {N,V}
    old_keys = d.keys
    old_vals = d.vals
    old_occupied = d.occupied
    old_cap = length(old_keys)

    new_cap = old_cap << 1
    new_mask = new_cap - 1
    new_keys = Memory{_Mask{N}}(undef, new_cap)
    new_vals = Memory{V}(undef, new_cap)
    new_occupied = zeros(UInt8, new_cap)

    @inbounds for i in 1:old_cap
        h2 = old_occupied[i]
        if h2 != 0x00
            k = old_keys[i]
            v = old_vals[i]
            idx = (hash(k) & new_mask) + 1
            while new_occupied[idx] != 0x00
                idx = (idx & new_mask) + 1
            end
            new_keys[idx] = k
            new_vals[idx] = v
            new_occupied[idx] = h2
        end
    end

    d.keys = new_keys
    d.vals = new_vals
    d.occupied = new_occupied
    d.mask = new_mask
    d.max_load = floor(Int, new_cap * _LOAD_FACTOR)
end

macro _get_value_loop()
    return esc(quote
        mask = d.mask
        h = hash(key)
        idx = (h & mask) + 1
        h2 = (h >> _RSHIFT) % UInt8 | 0x01
        @inbounds h2_idx = d.occupied[idx]
        @inbounds while h2_idx != 0x00
            if h2 == h2_idx && d.keys[idx] == key
                return d.vals[idx]
            end
            idx = (idx & mask) + 1
            h2_idx = d.occupied[idx]
        end
    end)
end

macro _get_zero_index_loop()
    return esc(quote
        mask = d.mask
        idx = (h & mask) + 1
        @inbounds h2_idx = d.occupied[idx]
        @inbounds while h2_idx != 0x00
            idx = (idx & mask) + 1
            h2_idx = d.occupied[idx]
        end
    end)
end

function Base.getindex(d::_Mask_Map, key::_Mask)
    @_get_value_loop()
    throw(KeyError(key))
end

function Base.get(f::Union{Function,Type}, d::_Mask_Map, key::_Mask)
    @_get_value_loop()
    return f()
end

function Base.get!(f::Union{Function,Type}, d::_Mask_Map, key::_Mask)
    @_get_value_loop()
    if d.count >= d.max_load
        _grow!(d)
        @_get_zero_index_loop()
    end
    val = f()
    @inbounds begin
        d.keys[idx] = key
        d.vals[idx] = val
        d.occupied[idx] = h2
        d.count += 1
    end
    return val
end

Base.length(d::_Mask_Map) = d.count
