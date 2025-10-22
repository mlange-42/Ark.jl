using Ark
using Test

using .TestTypes: Position, Velocity, Altitude, Health

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
        for _ in query
            entities, vec_pos, vec_vel = query[]
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
    for a in query
        ent, vec_pos, vec_vel = query[]
        @test a == 1
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

    query = Query(world, Val.((Position, Velocity)); without=Val.((Altitude,)))

    count = 0
    for a in query
        ent, vec_pos, vec_vel = query[]
        @test a == 1
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

    query = Query(world, Val.((Position, Velocity, Altitude)); optional=Val.((Altitude,)))

    count = 0
    indices = Vector{Int}()
    for a in query
        ent, vec_pos, vec_vel, vec_alt = query[]
        if a == 1
            @test vec_alt == nothing
        else
            @test vec_alt != nothing
        end
        push!(indices, a)
        for i in eachindex(ent)
            e = ent[i]
            count += 1
        end
    end
    @test count == 20
    @test indices == [1, 2]
end