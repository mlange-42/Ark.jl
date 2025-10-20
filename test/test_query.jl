
@testset "Filter" begin
    world = World()

    m1 = Map2{Altitude,Health}(world)
    m2 = Map2{Position,Velocity}(world)
    m3 = Map2{Position,Health}(world)

    for i in 1:10
        new_entity!(m1, Altitude(1), Health(2))
        new_entity!(m2, Position(i, i * 2), Velocity(1, 1))
        new_entity!(m3, Position(i, i * 2), Health(3))
    end

    query = Query2{Position,Velocity}(world)
    for i in 1:10
        count = 0
        for _ in query
            vec_pos, vec_vel = query[]
            # Alternatively:
            #vec_pos, vec_vel = get_components(query)
            for i in eachindex(vec_pos)
                pos = vec_pos[i]
                vel = vec_vel[i]
                vec_pos[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
                count += 1
            end
            @test_throws ErrorException new_entity!(m1, Altitude(1), Health(2))
            @test is_locked(world) == true
        end
        @test count == 10
        @test is_locked(world) == false
    end
end
