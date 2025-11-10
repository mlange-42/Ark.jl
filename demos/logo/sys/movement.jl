struct MovementSystem <: System
    max_speed::Float64
    max_acc::Float64
    max_acc_flee::Float64
    min_flee_distance::Float64
    max_flee_distance::Float64
    damp::Float64
end

MovementSystem(;
    max_speed::Float64         = 10.0,
    max_acc::Float64           = 0.08,
    max_acc_flee::Float64      = 0.1,
    min_flee_distance::Float64 = 50.0,
    max_flee_distance::Float64 = 200.0,
    damp::Float64              = 0.975) =
    MovementSystem(max_speed, max_acc, max_acc_flee, min_flee_distance, max_flee_distance, damp)

function update!(s::MovementSystem, world::World)
    mouse = get_resource(world, Mouse)

    min_dist = s.min_flee_distance
    dist_range = s.max_flee_distance - min_dist

    counter = rand(1:23)
    for (_, positions, velocities, targets) in @Query(world, (Position, Velocity, Target))
        @inbounds for i in eachindex(positions, velocities, targets)
            pos = positions[i]
            vel = velocities[i]
            trg = targets[i]

            attr_x, attr_y, _ = normalize(trg.x - pos.x, trg.y - pos.y)

            vx = vel.dx + attr_x * s.max_acc
            vy = vel.dy + attr_y * s.max_acc

            if mouse.inside
                rep_x, rep_y, rep_dist = normalize(pos.x - mouse.x, pos.y - mouse.y)
                rep_fac = min(1.0 - ((rep_dist - min_dist) / dist_range), 1.0)
                if rep_fac > 0
                    vx += rep_x * s.max_acc_flee * rep_fac
                    vy += rep_y * s.max_acc_flee * rep_fac
                end
            end

            vel_abs = vx * vx + vy * vy

            if vel_abs > 1.0
                vel_abs = sqrt(vel_abs)
                vx /= vel_abs
                vy /= vel_abs

                vel_abs = 1.0
            end

            if counter % 23 == 0
                vx += randn() * vel_abs * 0.2
                vx += randn() * vel_abs * 0.2
            end

            vx *= s.damp
            vy *= s.damp

            positions[i] = Position(pos.x + vx * s.max_speed, pos.y + vy * s.max_speed)
            velocities[i] = Velocity(vx, vy)

            counter += 1
        end
    end
end
