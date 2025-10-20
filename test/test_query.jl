
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

    filter = Filter2{Position,Velocity}(world)
    for i in 1:10
        for _ in filter
            vec_pos, vec_vel = get_components(filter)
            for i in eachindex(vec_pos)
                pos = vec_pos[i]
                vel = vec_vel[i]
                pos = Position(pos.x + vel.dx, pos.y + vel.dy)
                vec_pos[i] = pos
                println(vec_pos[i])
            end
        end
    end
end
