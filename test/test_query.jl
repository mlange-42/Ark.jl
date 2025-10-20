
@testset "Filter" begin
    world = World()

    filter = Filter2{Position,Velocity}(world)
    for i in filter
        println(i)
    end
end
