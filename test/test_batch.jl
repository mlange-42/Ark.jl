
@testset "Batch iterator test" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
        Altitude,
    )
    new_entity!(world, (Position(1, 2),))
    new_entity!(world, (Position(1, 2), Velocity(3, 4)))

    M = (@isdefined fake_types) ? 5 : 1
    storages = (world._storages[1],)
    batch = Batch{typeof(world),Tuple{Position},typeof(world).parameters[3],1,M}(world,
        [
            _BatchTable(world._tables[2], world._archetypes[2], UInt32(1), UInt32(1)),
            _BatchTable(world._tables[3], world._archetypes[3], UInt32(1), UInt32(1)),
        ], _QueryLock(false), _lock(world._lock))

    arches = 0
    for (ent, pos_col) in batch
        @test length(ent) == 1
        @test length(pos_col) == 1
        arches += 1
    end
    @test arches == 2

    # test closed batch
    @test_throws(
        "InvalidStateException: batch closed, batches can't be used multiple times",
        begin
            for x in batch
                nothing
            end
        end
    )

    batch = Batch{typeof(world),Tuple{Position},typeof(world).parameters[3],1,M}(world,
        [
            _BatchTable(world._tables[2], world._archetypes[2], UInt32(1), UInt32(2)),
            _BatchTable(world._tables[3], world._archetypes[3], UInt32(1), UInt32(2)),
        ], _QueryLock(false), _lock(world._lock))
    @test length(batch) == 2
    @test count_entities(batch) == 4

    close!(batch)
    # test closed batch
    @test_throws(
        "InvalidStateException: batch closed, batches can't be used multiple times",
        begin
            for x in batch
                nothing
            end
        end
    )
end

@testset "Batch show" begin
    world = World(
        Position,
        Velocity,
        Altitude,
    )
    batch = new_entities!(world, 100, (Position, Velocity))
    @test string(batch) == "Batch(entities=100, comp_types=(Position, Velocity))"
end

@testset "Batch eltype" begin
    world = World(
        Dummy,
        Position,
        Velocity => StructArrayStorage,
        Altitude,
        NoIsBits,
        Int64,
    )

    batch =
        new_entities!(world, 100, (Position(1, 1), Velocity(1, 1), Altitude(0), NoIsBits([]), Int64(1)); iterate=true)

    @inferred Tuple{
        SubArray{Entity,1,Entities,Tuple{UnitRange{UInt32}},true},
        FieldViews.FieldViewable{Position,1,SubArray{Position,1,Vector{Position},Tuple{UnitRange{UInt32}},true}},
        Ark.StructArrayView{
            Velocity,
            @NamedTuple{
                dx::SubArray{Float64,1,Vector{Float64},Tuple{UnitRange{UInt32}},true},
                dy::SubArray{Float64,1,Vector{Float64},Tuple{UnitRange{UInt32}},true},
            },
            UnitRange{UInt32},
        },
        FieldViews.FieldViewable{Altitude,1,SubArray{Altitude,1,Vector{Altitude},Tuple{UnitRange{UInt32}},true}},
        FieldViews.FieldViewable{NoIsBits,1,SubArray{NoIsBits,1,Vector{NoIsBits},Tuple{UnitRange{UInt32}},true}},
        SubArray{Int64,1,Vector{Int64},Tuple{UnitRange{UInt32}},true},
    } Base.eltype(typeof(batch))

    expected_type = Base.eltype(typeof(batch))
    @inferred Union{Nothing,Tuple{expected_type,Any}} Base.iterate(batch)
end
