using Printf

mutable struct ProfilingSystem <: System
    frames::Int
    _frame_counter::Int
    _last_time::UInt64
    _max_time::UInt64
    _sum_time::UInt64
end

function ProfilingSystem(frames::Int)
    ProfilingSystem(frames, 0, 0, 0, 0)
end

function initialize!(s::ProfilingSystem, world::World)
    s._last_time = time_ns()
end

function update!(s::ProfilingSystem, world::World)
    curr = time_ns()
    diff = curr - s._last_time

    s._sum_time += diff
    if diff > s._max_time
        s._max_time = diff
    end

    if s._frame_counter > 0 && s._frame_counter % s.frames == 0
        println(
            @sprintf(
                "%d avg: %6.2fms, max: %6.2fms",
                s._frame_counter,
                s._sum_time / (1_000_000 * s.frames), s._max_time / 1_000_000
            )
        )
        s._max_time = 0
        s._sum_time = 0
    end

    s._last_time = curr
    s._frame_counter += 1
end
