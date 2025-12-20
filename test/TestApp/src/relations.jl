
function test_relations()
    world = World(Position, Velocity, Altitude, Health, ChildOf)

    parent1 = new_entity!(world, (Position(0, 0),))
    parent2 = new_entity!(world, (Position(0, 0),))

    new_entities!(world, 10, (Position(0, 0), ChildOf()); relations=(ChildOf => parent1,))
    new_entities!(world, 10, (Position(0, 0), ChildOf()); relations=(ChildOf => parent2,))

    for (entities,) in Query(world, (); with=(ChildOf,), relations=(ChildOf => parent1,))
        if length(entities) != 10
            error("expected 10 entities")
        end
    end

    filter = Filter(world, (ChildOf,); relations=(ChildOf => parent1,))
    set_relations!(world, filter, (ChildOf => parent2,))
end
