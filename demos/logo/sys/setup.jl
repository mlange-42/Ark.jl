struct SetupSystem <: System
end

function initialize!(s::SetupSystem, world::World)
    for x in 100:300
        for y in 100:200
            new_entity!(world, (Position(x, y), Velocity(0, 0), Target(x, y)))
        end
    end
end
