
@testset "Query basic functionality" begin
    world = World(Position, Velocity, Altitude, Health)

    for i in 1:10
        new_entity!(world, (Altitude(1), Health(2)))
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
        new_entity!(world, (Position(i, i * 2), Health(3)))
    end

    for i in 1:10
        query = @Query(world, (Position, Velocity))
        @test query._has_excluded == false
        count = 0
        for (entities, vec_pos, vec_vel) in query
            @test isa(vec_pos, FieldsView{Position}) == true
            @test isa(vec_vel, FieldsView{Velocity}) == true
            @test length(entities) == length(vec_pos)
            @test length(entities) == length(vec_vel)
            for i in eachindex(vec_pos)
                pos = vec_pos[i]
                vel = vec_vel[i]
                vec_pos[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
                count += 1
            end
            @test_throws(
                "InvalidStateException: cannot modify a locked world: " *
                "collect entities into a vector and apply changes after query iteration has completed",
                new_entity!(world, (Altitude(1), Health(2)))
            )
            @test is_locked(world) == true
        end
        @test count == 10
        @test is_locked(world) == false
    end
end

@testset "Query with" begin
    world = World(Position, Velocity, Altitude)

    for i in 1:10
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1), Altitude(5)))
    end

    query = @Query(world, (Position, Velocity); with=(Altitude,))

    count = 0
    for (ent, vec_pos, vec_vel) in query
        for i in eachindex(ent)
            e = ent[i]
            @test has_components(world, e, Val.((Altitude,))) == true
            count += 1
        end
    end
    @test count == 10
end

@testset "Query without" begin
    world = World(Position, Velocity, Altitude)

    for i in 1:10
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1), Altitude(5)))
    end

    query = @Query(world, (Position, Velocity); without=(Altitude,))

    count = 0
    for (ent, vec_pos, vec_vel) in query
        for i in eachindex(ent)
            e = ent[i]
            @test has_components(world, e, Val.((Altitude,))) == false
            count += 1
        end
    end
    @test count == 10
end

@testset "Query optional" begin
    world = World(Position, Velocity, Altitude)

    for i in 1:10
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1), Altitude(5)))
    end

    query = @Query(world, (Position, Velocity, Altitude); optional=(Altitude,))

    count = 0
    indices = Vector{Int}()
    arch = 1
    for (ent, vec_pos, vec_vel, vec_alt) in query
        if arch == 1
            @test vec_alt == nothing
        else
            @test vec_alt != nothing
        end
        for i in eachindex(ent)
            e = ent[i]
            count += 1
        end
        arch += 1
    end
    @test count == 20
end

@testset "Query exclusive" begin
    world = World(Position, Velocity, Altitude, Health)

    for i in 1:10
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1), Altitude(5)))
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1), Altitude(5), Health(6)))
    end

    @test_throws(
        "ArgumentError: cannot use 'exclusive' together with 'without'",
        @Query(world, (Position, Velocity); without=(Altitude,), exclusive=true),
    )

    query = @Query(world, (Position, Velocity); with=(Altitude,), exclusive=true)
    @test query._has_excluded == true

    count = 0
    for (ent, vec_pos, vec_vel) in query
        for i in eachindex(ent)
            e = ent[i]
            @test has_components(world, e, Val.((Health,))) == false
            @test has_components(world, e, Val.((Altitude,))) == true
            count += 1
        end
    end
    @test count == 10
end

@testset "Query empty" begin
    world = World(Position, Velocity)

    for i in 1:10
        new_entity!(world, (Position(i, i * 2),))
    end

    query = @Query(world, (Position, Velocity))

    count = 0
    arches = 0
    for (ent, vec_pos) in query
        for i in eachindex(ent)
            count += 1
        end
        arches += 1
    end
    @test count == 0
    @test arches == 0
end

@testset "Query no comps" begin
    world = World(Position, Velocity)

    for i in 1:10
        new_entity!(world, (Position(i, i * 2),))
        new_entity!(world, (Velocity(i, i * 2),))
    end

    query = @Query(world, ())

    count = 0
    arches = 0
    for (ent,) in query
        for i in eachindex(ent)
            count += 1
        end
        arches += 1
    end
    @test count == 20
    @test arches == 2
end

@testset "Query StructArray" begin
    world = World(
        Position,
        Velocity => StructArrayStorage,
    )

    for i in 1:10
        new_entity!(world, (Position(0, 0), Velocity(i, i)))
    end

    for (entities, vec) in @Query(world, (Velocity,))
        @test isa(vec, StructArrayView)
        for i in eachindex(vec)
            pos = vec[i]
            vec[i] = Velocity(pos.dx + 1, pos.dy + 1)
        end
    end

    for arch in @Query(world, (Position, Velocity))
        @unpack e, pos, (dx, dy) = arch
        @test isa(e, Entities)
        @test isa(dx, SubArray{Float64})
        @test isa(dy, SubArray{Float64})
    end
end

@testset "Query FieldsView" begin
    world = World(
        Position,
        Velocity => StructArrayStorage,
        NoIsBits,
    )

    for i in 1:10
        new_entity!(world, (Position(i, i), Velocity(i, i), NoIsBits([])))
    end

    for columns in @Query(world, (Position, Velocity))
        @unpack _, (x, y), (dx, dy) = columns
        @test x isa FieldView
        @test y isa FieldView
        @test length(x) == 10
        @test x[1] == 1
        @test x[10] == 10
    end

    for (_, positions, no_isbits) in @Query(world, (Position, NoIsBits))
        @test positions isa FieldsView
        @test no_isbits isa SubArray
    end
end

@testset "Query macro missing argument" begin
    ex = Meta.parse("@Query(world)")
    @test_throws LoadError eval(ex)
end

@testset "Query macro unknown argument" begin
    ex = Meta.parse("@Query(world, (Position,); abc = 2)")
    @test_throws UndefVarError eval(ex)
end

@testset "Query macro invalid syntax" begin
    ex = Meta.parse("@Query(world, (Position,), xyz)")
    @test_throws LoadError eval(ex)
end

@testset "Query error messages" begin
    world = World(Position, Velocity)

    @test_throws(
        "ArgumentError: expected a tuple of Val types like Val.((Position, Velocity)), got Tuple{DataType, DataType}. " *
        "Consider using the related macro instead.",
        Query(world, (Position, Velocity))
    )

    query = @Query(world, (Position, Velocity))
    for _ in query
    end
    @test_throws(
        "InvalidStateException: query closed, queries can't be used multiple times",
        for _ in query
        end
    )
end
