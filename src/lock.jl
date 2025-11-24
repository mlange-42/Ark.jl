mutable struct _Lock
    const pool::_BitPool
    lock_bits::UInt64
end

function _Lock()
    _Lock(_BitPool(), 0)
end

function _lock(lock::_Lock)::Int
    l = _get_bit(lock.pool)
    lock.lock_bits |= UInt64(1) << (l - 1)
    return l
end

function _unlock(lock::_Lock, b::Int)
    if ((lock.lock_bits >> (b - 1)) & UInt64(0x01)) == 0
        throw(
            InvalidStateException(
                "unbalanced unlock. Did you close a query that was already iterated?",
                :unbalanced_lock,
            ),
        )
    end
    lock.lock_bits &= ~(UInt64(1) << (b - 1))
    _recycle(lock.pool, b)
end

function _is_locked(lock::_Lock)::Bool
    return lock.lock_bits != 0
end

function _reset!(lock::_Lock)
    _reset!(lock.pool)
end
