
@testset "Relations remove target" begin
    world = World(Position, ChildOf, ChildOf2)

    parent1 = new_entity!(world, ())
    parent2 = new_entity!(world, ())

    new_entities!(world, 100, (Position, ChildOf); relations=(ChildOf => parent1,)) do (_, positions, children)
        for i in eachindex(positions, children)
            positions[i] = Position(i, i)
            children[i] = ChildOf()
        end
    end

    new_entities!(world, 50, (Position, ChildOf); relations=(ChildOf => parent2,)) do (_, positions, children)
        for i in eachindex(positions, children)
            positions[i] = Position(i, i)
            children[i] = ChildOf()
        end
    end

    tables = 0
    count = 0
    for (_, children) in Query(world, (ChildOf,))
        tables += 1
        count += length(children)
    end
    @test tables == 2
    @test count == 150

    remove_entity!(world, parent1)

    count = 0
    for (_, children) in Query(world, (ChildOf,); relations=(ChildOf => zero_entity,))
        count += length(children)
    end
    @test count == 100

    remove_entity!(world, parent2)

    count = 0
    for (_, children) in Query(world, (ChildOf,); relations=(ChildOf => zero_entity,))
        count += length(children)
    end
    @test count == 150

    @test length(world._tables) == 4

    parent3 = new_entity!(world, ())
    parent4 = new_entity!(world, ())
    e1 = new_entity!(world, (Position(0, 0), ChildOf()); relations=(ChildOf => parent3,))
    e2 = new_entity!(world, (Position(0, 0), ChildOf()); relations=(ChildOf => parent4,))
    @test length(world._tables) == 4

    parents = get_relations(world, e1, (ChildOf,))
    @test parents == (parent3,)
    parents = get_relations(world, e2, (ChildOf,))
    @test parents == (parent4,)
end

@testset "Relations multiple" begin end
