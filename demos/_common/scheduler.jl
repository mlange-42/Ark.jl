
abstract type System end

function initialize!(::System, ::World) end
function update!(::System, ::World) end
function finalize!(::System, ::World) end

mutable struct Scheduler{ST<:Tuple}
    world::World
    systems::ST
end

function initialize!(s::S) where {S<:Scheduler}
    add_resource!(s.world, Tick(0))
    for sys in s.systems
        initialize!(sys, s.world)
    end
    GC.gc()
end

function update!(s::S) where {S<:Scheduler}
    if has_resource(s.world, Terminate) && get_resource(s.world, Terminate).stop
        return false
    end

    for sys in s.systems
        update!(sys, s.world)
    end
    get_resource(s.world, Tick).tick += 1

    return true
end

function finalize!(s::S) where {S<:Scheduler}
    for sys in s.systems
        finalize!(sys, s.world)
    end
end
