struct TerminationSystem <: System
    max_ticks::Int
end

function initialize!(s::TerminationSystem, world::World)
    add_resource!(world, Terminate(false))
end

function update!(s::TerminationSystem, world::World)
    tick = get_resource(world, Tick).tick
    if s.max_ticks >= 0 && tick >= s.max_ticks
        get_resource(world, Terminate).stop = true
    end
end
