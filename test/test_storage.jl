using Ark
using Test

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
end