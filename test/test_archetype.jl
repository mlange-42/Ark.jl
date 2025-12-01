
@testset "_TableIDs" begin
    t1 = Ref(_new_table(UInt32(1), UInt32(1)))
    t2 = Ref(_new_table(UInt32(2), UInt32(1)))
    t3 = Ref(_new_table(UInt32(3), UInt32(1)))
    t4 = Ref(_new_table(UInt32(4), UInt32(1)))
    t5 = Ref(_new_table(UInt32(5), UInt32(1)))
    t6 = Ref(_new_table(UInt32(6), UInt32(1)))

    ids = _TableIDs(t5, t4, t3, t2, t1)

    @test ids.tables == [t5, t4, t3, t2, t1]
    @test ids.indices[5] == 1
    @test ids.indices[1] == 5

    _add_table!(ids, t6)
    @test ids.tables == [t5, t4, t3, t2, t1, t6]
    @test ids.indices[6] == 6

    @test _remove_table!(ids, t3[]) == true
    @test ids.tables == [t5, t4, t6, t2, t1]
    @test ids.indices[6] == 3

    @test _remove_table!(ids, t1[]) == true
    @test ids.tables == [t5, t4, t6, t2]
    @test ids.indices[6] == 3

    @test _remove_table!(ids, t1[]) == false
    @test ids.tables == [t5, t4, t6, t2]
    @test ids.indices[6] == 3
end

@testset "_Archetype _add_table!" begin
    # TODO: re-activate, but use world and entity creations
    """
    world = World(Dummy, Position, ChildOf)
    child_id = 3 + offset_ID

    t1 =
        _find_or_create_table!(
            world,
            world._tables[1],
            (2 + offset_ID, child_id),
            (),
            (child_id,),
            (_new_entity(2, 1),),
        )
    t2 =
        _find_or_create_table!(
            world,
            world._tables[1],
            (2 + offset_ID, child_id),
            (),
            (child_id,),
            (_new_entity(99, 1),),
        )

    arch = world._archetypes[2]

    @test arch.relations == [child_id]
    @test length(arch.index) == 1

    index = arch.index[1]
    @test index[2].tables == [world._tables[t1]]
    @test index[99].tables == [world._tables[t2]]

    table, found = _get_table(world, arch, [child_id => _new_entity(99, 1)])
    @test found == true
    @test table == world._tables[t2]

    table, found = _get_table(world, arch, [child_id => _new_entity(101, 1)])
    @test found == false
    """
end

@testset "_Archetype has relations" begin
    world = World(Dummy, Position, ChildOf)

    new_entity!(world, (Position(0, 0),))
    @test _has_relations(world._archetypes[2]) == false

    # TODO: re-activate this
    #new_entity!(world, (ChildOf(),))
    #@test _has_relations(world._archetypes[3]) == true
end
