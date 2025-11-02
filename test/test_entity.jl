
@testset "Entity is_zero" begin
    world = World()

    @test is_zero(zero_entity) == true
    @test is_zero(_new_entity(1, 0)) == true

    entity = add_entity!(world, ())
    @test is_zero(entity) == false
end

@testset "Entities interface tests" begin
    col = _new_entities_column()
    push!(col._data, _new_entity(1, 0))
    push!(col._data, _new_entity(2, 0))
    push!(col._data, _new_entity(3, 0))

    # Test getindex
    @test col[1] == _new_entity(1, 0)
    @test col[3] == _new_entity(3, 0)

    # Test length
    @test length(col) == 3

    # Test eachindex
    indices = collect(eachindex(col))
    @test indices == [1, 2, 3]

    # Test enumerate
    values = [(i, v) for (i, v) in enumerate(col)]
    @test values == [(1, _new_entity(1, 0)), (2, _new_entity(2, 0)), (3, _new_entity(3, 0))]

    # Test iteration
    collected = [v for v in col]
    @test collected == [_new_entity(1, 0), _new_entity(2, 0), _new_entity(3, 0)]

    @test firstindex(col) == 1
    @test lastindex(col) == 3
    @test eltype(col) == Entity
    @test size(col) == (length(col),)
    @test IndexStyle(col) == IndexLinear()
end
