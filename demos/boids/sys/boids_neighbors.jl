
struct BoidsNeighbors <: System
    max_distance::Float64
end

BoidsNeighbors(;
    max_distance::Float64,
) = BoidsNeighbors(max_distance)

function update!(s::BoidsNeighbors, world::World)
    tick = get_resource(world, Tick).tick
    max_dist_sq = s.max_distance * s.max_distance
    # TODO: use a grid for acceleration
    for (entities1, positions1, neighbors, updates) in Query(world, (Position, Neighbors, UpdateStep))
        for i in eachindex(positions1, neighbors, updates)
            if tick % 30 != updates[i].step
                continue
            end
            entity1 = entities1[i]
            neigh = neighbors[i]
            resize!(neigh.n, 0)

            pos1 = positions1[i]
            for (entities2, positions2) in Query(world, (Position,))
                for j in eachindex(entities2, positions2)
                    entity2 = entities2[j]
                    if entity1 == entity2
                        continue
                    end
                    pos2 = positions2[j]
                    if distance_sq(pos1.p, pos2.p) <= max_dist_sq
                        push!(neigh.n, entity2)
                    end
                end
            end
        end
    end
end
