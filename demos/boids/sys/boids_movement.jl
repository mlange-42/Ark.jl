
struct BoidsMovement <: System
    avoid_factor::Float64
    avoid_distance::Float64
    align_factor::Float64
    cohesion_factor::Float64
    min_speed::Float64
    max_speed::Float64
    margin::Float64
    margin_factor::Float64
end

BoidsMovement(;
    avoid_factor::Float64,
    avoid_distance::Float64,
    align_factor::Float64,
    cohesion_factor::Float64,
    min_speed::Float64,
    max_speed::Float64,
    margin::Float64,
    margin_factor::Float64,
) = BoidsMovement(
    avoid_factor,
    avoid_distance,
    align_factor,
    cohesion_factor,
    min_speed,
    max_speed,
    margin,
    margin_factor,
)

function update!(s::BoidsMovement, world::World)
    size = get_resource(world, WorldSize)
    avoid_dist_sq = s.avoid_distance * s.avoid_distance
    for (_, positions, velocities, neighbors) in Query(world, (Position, Velocity, Neighbors))
        for i in eachindex(positions, velocities, neighbors)
            pos = positions[i].p
            vel = velocities[i].v
            neigh = neighbors[i].n

            close_x, close_y = 0.0, 0.0
            avg_x, avg_y = 0.0, 0.0
            avg_vx, avg_vy = 0.0, 0.0
            for n in neigh
                other_pos, other_vel = get_components(world, n, (Position, Velocity))
                dist_sq = distance_sq(pos, other_pos.p)
                if dist_sq <= avoid_dist_sq
                    close_x += pos[1] - other_pos.p[1]
                    close_y += pos[2] - other_pos.p[2]
                end
                avg_x += other_pos.p[1]
                avg_y += other_pos.p[2]
                avg_vx += other_vel.v[1]
                avg_vy += other_vel.v[2]
            end

            vx, vy = vel[1], vel[2]
            if length(neigh) > 0
                avg_x /= length(neigh)
                avg_y /= length(neigh)
                avg_vx /= length(neigh)
                avg_vy /= length(neigh)
                vx +=
                    close_x * s.avoid_factor + (avg_vx - vel[1]) * s.align_factor +
                    (avg_x - pos[1]) * s.cohesion_factor
                vy +=
                    close_y * s.avoid_factor + (avg_vy - vel[1]) * s.align_factor +
                    (avg_y - pos[2]) * s.cohesion_factor
            end

            if pos[1] < s.margin
                vx += s.margin_factor
            elseif pos[1] > size.width - s.margin
                vx -= s.margin_factor
            end
            if pos[2] < s.margin
                vy += s.margin_factor
            elseif pos[2] > size.height - s.margin
                vy -= s.margin_factor
            end

            speed = sqrt(vx * vx + vy * vy)
            if speed < s.min_speed
                vx = (vx / speed) * s.min_speed
                vy = (vy / speed) * s.min_speed
            elseif speed > s.max_speed
                vx = (vx / speed) * s.max_speed
                vy = (vy / speed) * s.max_speed
            end

            velocities[i] = Velocity((vx, vy))
            positions[i] = Position((pos[1] + vx, pos[2] + vy))
        end
    end

    for (_, velocities, rotations) in Query(world, (Velocity, Rotation))
        rotations.r .= direction_to_rotation.(velocities.v)
    end
end
