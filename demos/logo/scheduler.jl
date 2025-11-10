
abstract type System end

function initialize!(::System, ::World) end
function update!(::System, ::World) end
function finalize!(::System, ::World) end

mutable struct Scheduler{ST<:Tuple}
    world::World
    systems::ST
end

function initialize!(s::Scheduler)
    for sys in s.systems
        initialize!(sys, s.world)
    end
    GC.gc()
end

function update!(s::Scheduler)
    for sys in s.systems
        update!(sys, s.world)
    end
end

function finalize!(s::Scheduler)
    for sys in s.systems
        finalize!(sys, s.world)
    end
end
