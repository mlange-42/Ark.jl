
struct DecisionGrazers <: System
    to_graze::Vector{Entity}
    to_move::Vector{Entity}
end

DecisionGrazers() = DecisionGrazers(Vector{Entity}(), Vector{Entity}())

function update!(s::DecisionGrazers, world::World)
    resize!(s.to_graze, 0)
    resize!(s.to_move, 0)

    grass = get_resource(world, GrassGrid).grass[]

    for (entities, positions, genes) in Query(world, (Position, Genes); with=(Moving,))
        for i in eachindex(entities, positions)
            pos = positions[i]
            gene = genes[i]
            cx, cy = floor(Int, pos[1]) + 1, floor(Int, pos[2]) + 1
            grass_here = grass[cx, cy]
            if grass_here > gene.graze_thresh
                push!(s.to_graze, entities[i])
            end
        end
    end
    for (entities, positions, genes) in Query(world, (Position, Genes); with=(Grazing,))
        for i in eachindex(entities, positions)
            pos = positions[i]
            gene = genes[i]
            cx, cy = floor(Int, pos[1]) + 1, floor(Int, pos[2]) + 1
            grass_here = grass[cx, cy]
            if grass_here < gene.graze_thresh * gene.move_thresh
                push!(s.to_move, entities[i])
            end
        end
    end

    for e in s.to_graze
        exchange_components!(world, e; add=(Grazing(),), remove=(Moving,))
    end
    for e in s.to_move
        exchange_components!(world, e; add=(Moving(),), remove=(Grazing,))
    end
end
