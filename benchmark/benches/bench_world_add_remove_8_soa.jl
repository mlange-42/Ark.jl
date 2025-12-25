
function setup_world_add_remove_8_soa(n_entities::Int)
    world = World(
        Position => StructArrayStorage,
        CompN{1} => StructArrayStorage,
        CompN{2} => StructArrayStorage,
        CompN{3} => StructArrayStorage,
        CompN{4} => StructArrayStorage,
        CompN{5} => StructArrayStorage,
        CompN{6} => StructArrayStorage,
        CompN{7} => StructArrayStorage,
        CompN{8} => StructArrayStorage,
    )

    entities = Vector{Entity}()
    for i in 1:n_entities
        e = new_entity!(world, (Position(i, i * 2),))
        push!(entities, e)
    end

    for e in entities
        add_components!(world, e,
            (CompN{1}(0, 0), CompN{2}(0, 0), CompN{3}(0, 0), CompN{4}(0, 0),
                CompN{5}(0, 0), CompN{6}(0, 0), CompN{7}(0, 0), CompN{8}(0, 0)),
        )
        remove_components!(world, e,
            (CompN{1}, CompN{2}, CompN{3}, CompN{4},
                CompN{5}, CompN{6}, CompN{7}, CompN{8}),
        )
    end

    return (entities, world)
end

function benchmark_world_add_remove_8_soa(args, n)
    entities, world = args
    for e in entities
        add_components!(
            world,
            e,
            (CompN{1}(0, 0), CompN{2}(0, 0), CompN{3}(0, 0), CompN{4}(0, 0),
                CompN{5}(0, 0), CompN{6}(0, 0), CompN{7}(0, 0), CompN{8}(0, 0)),
        )
    end
    for e in entities
        remove_components!(
            world,
            e,
            (CompN{1}, CompN{2}, CompN{3}, CompN{4},
                CompN{5}, CompN{6}, CompN{7}, CompN{8}),
        )
    end
end

for n in (100, 10_000)
    SUITE["benchmark_world_add_remove_8_soa n=$(n)"] =
        @be setup_world_add_remove_8_soa($n) benchmark_world_add_remove_8_soa(_, $n) seconds = SECONDS
end
