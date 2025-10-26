
function setup_world_add_remove_large_world(n_entities::Int)
    world = World(Position, Velocity,
        CompN{1}, CompN{2}, CompN{3}, CompN{4}, CompN{5},
        CompN{6}, CompN{7}, CompN{8}, CompN{9}, CompN{10},
        CompN{11}, CompN{12}, CompN{13}, CompN{14}, CompN{15},
        CompN{16}, CompN{17}, CompN{18}, CompN{19}, CompN{20},
        CompN{21}, CompN{22}, CompN{23}, CompN{24}, CompN{25},
        CompN{26}, CompN{27}, CompN{28}, CompN{29}, CompN{30},
    )

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(world, (Position(i, i * 2),))
        push!(entities, e)
    end

    for e in entities
        add_components!(world, e, (Velocity(0, 0),))
        remove_components!(world, e, Val.((Velocity,)))
    end

    return (entities, world)
end

function benchmark_world_add_remove_large_world(args, n)
    entities, world = args
    for e in entities
        add_components!(world, e, (Velocity(0, 0),))
        remove_components!(world, e, Val.((Velocity,)))
    end
end

for n in (100, 10_000)
    SUITE["benchmark_world_add_remove_large_world n=$n"] = @be setup_world_add_remove_large_world($n) benchmark_world_add_remove_large_world(_, $n) seconds = SECONDS
end
