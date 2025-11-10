struct MovementSystem <: System
    max_speed::Float64
    max_acc::Float64
    max_acc_flee::Float64
    min_flee_distance::Float64
    max_flee_distance::Float64
    damp::Float64
end

MovementSystem(;
    max_speed::Float64         = 1.0,
    max_acc::Float64           = 1.0,
    max_acc_flee::Float64      = 2.0,
    min_flee_distance::Float64 = 10.0,
    max_flee_distance::Float64 = 50.0,
    damp::Float64              = 0.1) =
    MovementSystem(max_speed, max_acc, max_acc_flee, min_flee_distance, max_flee_distance, damp)

function update!(s::MovementSystem, world::World)
    mouse = get_resource(world, Mouse)
end
