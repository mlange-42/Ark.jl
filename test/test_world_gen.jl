using .TestTypes: Position, Velocity, Altitude, Health

@testset "World creation" begin
    world = WorldGen(Position, Velocity)
    @test isa(world, WorldGen)

    @test _component_id(world, Velocity) == 2
    @test _component_id(world, Position) == 1
    @test_throws ErrorException _component_id(world, Altitude)

    @test isa(_get_storage(world, Position), _ComponentStorage{Position})
    @test isa(_get_storage(world, Val{Position}()), _ComponentStorage{Position})
    @test isa(_get_storage_by_id(world, Val(1)), _ComponentStorage{Position})
end

@testset "World create archetype" begin
    world = WorldGen(Position, Velocity)

    arch1 = _find_or_create_archetype!(world, world._graph.nodes[1], (UInt8(1),), ())
    @test arch1 == 2

    arch2 = _find_or_create_archetype!(world, world._graph.nodes[1], (UInt8(1), UInt8(2)), ())
    @test arch2 == 3

    arch3 = _find_or_create_archetype!(world, world._graph.nodes[1], (UInt8(1),), ())
    @test arch3 == arch1
end
