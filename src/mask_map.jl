
isdefined(@__MODULE__, :Memory) || const Memory = Vector # Compat for Julia < 1.11

const LOAD_FACTOR = 0.75

mutable struct _Mask_Map{N, V}
    keys::Memory{_Mask{N}}
    vals::Memory{V}
    occupied::Memory{Bool} 
    count::Int
    mask::Int
    max_load::Int
    function _Mask_Map{N, V}(initial_size::Int=2) where {N, V}
        # Force power of 2 size
        sz = nextpow(2, initial_size)
        keys = Memory{_Mask{N}}(undef, sz)
        vals = Memory{V}(undef, sz)
        occupied = zeros(Bool, sz)
        max_load = floor(Int, sz * LOAD_FACTOR)
        new{N, V}(keys, vals, occupied, 0, sz - 1, max_load)
    end
end

function _grow!(d::_Mask_Map{N, V}) where {N, V}
    old_keys = d.keys
    old_vals = d.vals
    old_occupied = d.occupied
    old_cap = length(old_keys)
    
    new_cap = old_cap << 1
    new_mask = new_cap - 1
    
    new_keys = Memory{_Mask{N}}(undef, new_cap)
    new_vals = Memory{V}(undef, new_cap)
    new_occupied = zeros(Bool, new_cap)
    
    @inbounds for i in 1:old_cap
        if old_occupied[i] == true
            k = old_keys[i]
            v = old_vals[i]            
            idx = (hash(k) & new_mask) + 1
            
            while new_occupied[idx] == true
                idx = (idx & new_mask) + 1
            end
            
            new_keys[idx] = k
            new_vals[idx] = v
            new_occupied[idx] = true
        end
    end

    d.keys = new_keys
    d.vals = new_vals
    d.occupied = new_occupied
    d.mask = new_mask
    d.max_load = floor(Int, new_cap * LOAD_FACTOR)
    return nothing
end

function Base.getindex(d::_Mask_Map, key::_Mask)
    mask = d.mask
    idx = (hash(key) & mask) + 1
    @inbounds while d.occupied[idx] == true
        if d.keys[idx] == key
            return d.vals[idx]
        end
        idx = (idx & mask) + 1
    end
    throw(KeyError(key))
end

function Base.get(f::Union{Function, Type}, d::_Mask_Map, key::_Mask)
    mask = d.mask
    idx = (hash(key) & mask) + 1
    @inbounds while d.occupied[idx] == true
        if d.keys[idx] == key
            return d.vals[idx]
        end
        idx = (idx & mask) + 1
    end
    return f()
end

function Base.get!(f::Union{Function, Type}, d::_Mask_Map, key::_Mask)
    if d.count >= d.max_load
        _grow!(d)
    end

    mask = d.mask
    idx = (hash(key) & mask) + 1
    @inbounds while d.occupied[idx] == true
        if d.keys[idx] == key
            return d.vals[idx]
        end
        idx = (idx & mask) + 1
    end
        
    val = f()
    @inbounds begin
        d.keys[idx] = key
        d.vals[idx] = val
        d.occupied[idx] = true
        d.count += 1
    end
    return val
end

Base.length(d::_Mask_Map) = d.count
