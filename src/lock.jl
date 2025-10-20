mutable struct _Lock
    pool::_BitPool
    lock_bits::UInt64
end

function _Lock()
    _Lock(_BitPool(), 0)
end

function _lock(lock::_Lock)::UInt8
    l = _get_bit(lock.pool)
    lock.lock_bits |= UInt64(1) << (l - 1)
    return l
end

function _unlock(lock::_Lock, b::UInt8)
    if ((lock.lock_bits >> (b - 1)) & 0x01) == 0
        error("unbalanced unlock. Did you close a query that was already iterated?")
    end
    lock.lock_bits &= ~(UInt64(1) << (b - 1))
    _recycle(lock.pool, b)
end

function _is_locked(lock::_Lock)::Bool
    return lock.lock_bits != 0
end
