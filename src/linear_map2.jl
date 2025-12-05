
mutable struct _Linear_Map2{K,V}
    keys::Memory{K}
    vals::Memory{V}
    occupied::Memory{UInt8}
    count::Int
    n_tombs::Int
    mask::Int
    max_load::Int
    max_tombs::Int
    function _Linear_Map2{K,V}(initial_size::Int=8) where {K,V}
        # Force power of 2 size
        sz = nextpow(2, initial_size)
        keys = Memory{K}(undef, sz)
        vals = Memory{V}(undef, sz)
        occupied = zeros(UInt8, sz)
        max_load = floor(Int, sz * _LOAD_FACTOR)
        max_tombs = floor(Int, sz * 0.5)
        new{K,V}(keys, vals, occupied, 0, 0, sz - 1, max_load, max_tombs)
    end
end

function _grow_or_compact!(d::_Linear_Map2{K,V}, grow) where {K,V}
    old_keys = d.keys
    old_vals = d.vals
    old_occupied = d.occupied
    old_cap = length(old_keys)
 
    new_cap = grow ? old_cap << 1 : old_cap
    new_mask = new_cap - 1
    new_keys = Memory{K}(undef, new_cap)
    new_vals = Memory{V}(undef, new_cap)
    new_occupied = zeros(UInt8, new_cap)

    @inbounds for i in 1:old_cap
        h2 = old_occupied[i]
        if h2 != 0x00 && h2 != 0xff
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
    d.count -= d.n_tombs
    d.n_tombs = 0
    d.mask = new_mask
    d.max_load = floor(Int, new_cap * _LOAD_FACTOR)
    d.max_tombs = floor(Int, new_cap * 0.5)
end

macro _get_value_loop2()
    return esc(quote
        mask = d.mask
        h = hash(key)
        idx = (h & mask) + 1
        h2 = (((h >> _RSHIFT) % UInt8) & 0x7f) | 0x01
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

macro _get_zero_index_loop2()
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

function Base.getindex(d::_Linear_Map2, key)
    @_get_value_loop2()
    throw(KeyError(key))
end

function Base.get(f::Union{Function,Type}, d::_Linear_Map2, key)
    @_get_value_loop2()
    return f()
end

function Base.get!(f::Union{Function,Type}, d::_Linear_Map2, key)
    @_get_value_loop2()
    if d.count >= d.max_load
        _grow_or_compact!(d, true)
        @_get_zero_index_loop2()
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

function Base.delete!(d::_Linear_Map2, key)
    mask = d.mask
    h = hash(key)
    found = false
    idx = (h & mask) + 1
    h2 = (((h >> _RSHIFT) % UInt8) & 0x7f) | 0x01
    @inbounds h2_idx = d.occupied[idx]
    @inbounds while h2_idx != 0x00
        if h2 == h2_idx && d.keys[idx] == key
            found = true
            break
        end
        idx = (idx & mask) + 1
        h2_idx = d.occupied[idx]
    end
    !found && return d
    @inbounds d.occupied[idx] = 0xff
    d.n_tombs += 1
    if d.n_tombs > d.max_tombs
        _grow_or_compact!(d, false)
    end
    return d
end

function Base.haskey(d::_Linear_Map2, key)
    mask = d.mask
    h = hash(key)
    found = false
    idx = (h & mask) + 1
    h2 = (((h >> _RSHIFT) % UInt8) & 0x7f) | 0x01
    @inbounds h2_idx = d.occupied[idx]
    @inbounds while h2_idx != 0x00
        if h2 == h2_idx && d.keys[idx] == key
            found = true
            break
        end
        idx = (idx & mask) + 1
        h2_idx = d.occupied[idx]
    end
    return found
end

function Base.setindex!(d::_Linear_Map2, value, key)
    mask = d.mask
    h = hash(key)
    found = false
    idx = (h & mask) + 1
    h2 = (((h >> _RSHIFT) % UInt8) & 0x7f) | 0x01
    @inbounds h2_idx = d.occupied[idx]
    @inbounds while h2_idx != 0x00
        if h2 == h2_idx && d.keys[idx] == key
            found = true
            break
        end
        idx = (idx & mask) + 1
        h2_idx = d.occupied[idx]
    end
    if found
        @inbounds d.vals[idx] = value
    else
        if d.count >= d.max_load
            _grow_or_compact!(d, true)
            @_get_zero_index_loop2()
        end
        @inbounds begin
            d.keys[idx] = key
            d.vals[idx] = value
            d.occupied[idx] = h2
            d.count += 1
        end
    end
    return value
end

function Base.iterate(d::_Linear_Map2, state=1)
    for idx in state:length(d.occupied)
        h2 = d.occupied[idx]
        if h2 != 0x00 && h2 != 0xff
            return (d.keys[idx] => d.vals[idx], idx+1)
        end
    end
    return nothing
end

function Base.empty!(d::_Linear_Map2)
    d.occupied .= 0xff
    _grow_or_compact!(d, false)
end

Base.length(d::_Linear_Map2) = d.count - d.n_tombs
