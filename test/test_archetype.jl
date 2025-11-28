
@testset "_TableIDs" begin
    ids = _TableIDs(9, 8, 7, 6, 5)

    @test ids.ids == [9, 8, 7, 6, 5]
    @test ids.indices[9] == 1
    @test ids.indices[5] == 5

    _add_table!(ids, 10)
    @test ids.ids == [9, 8, 7, 6, 5, 10]
    @test ids.indices[10] == 6

    @test _remove_table!(ids, 8) == true
    @test ids.ids == [9, 10, 7, 6, 5]
    @test ids.indices[10] == 2

    @test _remove_table!(ids, 5) == true
    @test ids.ids == [9, 10, 7, 6]
    @test ids.indices[10] == 2

    @test _remove_table!(ids, 5) == false
    @test ids.ids == [9, 10, 7, 6]
    @test ids.indices[10] == 2
end

@testset "_Archetype has relations" begin
    world = World(Dummy, Position, ChildOf)

    new_entity!(world, (Position(0, 0),))
    new_entity!(world, (ChildOf(),))

    @test _has_relations(world._archetypes[2]) == false
    @test _has_relations(world._archetypes[3]) == true
end
