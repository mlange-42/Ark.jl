
@testset "Entity is_zero" begin
    world = World()

    @test is_zero(zero_entity) == true
    @test is_zero(_new_entity(1, 0)) == true

    entity = new_entity!(world)
    @test is_zero(entity) == false
end
