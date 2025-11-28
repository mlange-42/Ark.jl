
@testset "_TableIDs" begin
    ids = _TableIDs(9, 8, 7, 6, 5)

    @test ids.ids == [9, 8, 7, 6, 5]
    @test ids.indices[9] == 1
    @test ids.indices[5] == 5

    _add_table!(ids, UInt32(10))
    @test ids.ids == [9, 8, 7, 6, 5, 10]
    @test ids.indices[10] == 6

    @test _remove_table!(ids, UInt32(8)) == true
    @test ids.ids == [9, 10, 7, 6, 5]
    @test ids.indices[10] == 2

    @test _remove_table!(ids, UInt32(5)) == true
    @test ids.ids == [9, 10, 7, 6]
    @test ids.indices[10] == 2

    @test _remove_table!(ids, UInt32(5)) == false
    @test ids.ids == [9, 10, 7, 6]
    @test ids.indices[10] == 2
end

@testset "_Archetype _add_table!" begin
    world = World(Dummy, Position, ChildOf)
    child_id = 3 + offset_ID

    t1 =
        _find_or_create_table!(world, world._tables[1], (2 + offset_ID, child_id), (), [child_id => _new_entity(2, 1)])
    t2 =
        _find_or_create_table!(world, world._tables[1], (2 + offset_ID, child_id), (), [child_id => _new_entity(99, 1)])

    arch = world._archetypes[2]

    @test arch.relations == [child_id]
    @test length(arch.index) == 1

    index = arch.index[1]
    @test index[2].ids == [2]
    @test index[99].ids == [3]

    table, found = _get_table(world, arch, [child_id => _new_entity(99, 1)])
    @test found == true
    @test table == world._tables[t2]

    table, found = _get_table(world, arch, [child_id => _new_entity(101, 1)])
    @test found == false
end

@testset "_Archetype has relations" begin
    world = World(Dummy, Position, ChildOf)

    new_entity!(world, (Position(0, 0),))
    @test _has_relations(world._archetypes[2]) == false

    # TODO: re-activate this
    #new_entity!(world, (ChildOf(),))
    #@test _has_relations(world._archetypes[3]) == true
end
