
@testset "Query basic functionality" begin
    world = World(Position, Velocity, Altitude, Health)

    for i in 1:10
        new_entity!(world, (Altitude(1), Health(2)))
        new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
        new_entity!(world, (Position(i, i * 2), Health(3)))
    end

    query = @Query(world, (Position, Velocity))
    for i in 1:10
        count = 0
        for (entities, vec_pos, vec_vel) in query
            @test length(entities) == length(vec_pos)
            @test length(entities) == length(vec_vel)
            for i in eachindex(vec_pos)
                pos = vec_pos[i]
                vel = vec_vel[i]
                vec_pos[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
                count += 1
            end
            @test_throws ErrorException new_entity!(world, (Altitude(1), Health(2)))
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

    query = @Query(world, (Position, Velocity), with = (Altitude,))

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

    query = @Query(world, (Position, Velocity), without = (Altitude,))

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

    query = @Query(world, (Position, Velocity, Altitude), optional = (Altitude,))

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

@testset "Query macro missing argument" begin
    ex = Meta.parse("@Query(world)")
    @test_throws LoadError eval(ex)
end

@testset "Query macro unknown argument" begin
    ex = Meta.parse("@Query(world, (Position,), abc = 2)")
    @test_throws LoadError eval(ex)
end

@testset "Query macro invalid syntax" begin
    ex = Meta.parse("@Query(world, (Position,), xyz)")
    @test_throws LoadError eval(ex)
end