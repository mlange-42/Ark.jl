
struct BoidsNeighbors <: System
end

function update!(s::BoidsNeighbors, world::World)
    tick = get_resource(world, Tick).tick
    max_dist_sq = 25 * 25
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
