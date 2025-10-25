
@testset "Column interface tests" begin
    col = _new_column(Int)
    push!(col._data, 10)
    push!(col._data, 20)
    push!(col._data, 30)

    # Test getindex
    @test col[1] == 10
    @test col[3] == 30

    # Test setindex!
    col[2] = 99
    @test col[2] == 99

    # Test length
    @test length(col) == 3

    # Test eachindex
    indices = collect(eachindex(col))
    @test indices == [1, 2, 3]

    # Test enumerate
    values = [(i, v) for (i, v) in enumerate(col)]
    @test values == [(1, 10), (2, 99), (3, 30)]

    # Test iteration
    collected = [v for v in col]
    @test collected == [10, 99, 30]

    @test firstindex(col) == 1
    @test lastindex(col) == 3
    @test eltype(col) == Int
    @test size(col) == (length(col),)
    @test IndexStyle(col) == IndexLinear()
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
