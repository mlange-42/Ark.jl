
@testset "StructArray basic functionality" begin
    a = _StructArray(Position)

    @test isa(a.components.x, Vector{Float64})
    @test isa(a.components.y, Vector{Float64})

    push!(a, Position(1, 2))

    @test length(a.components.x) == 1
    @test length(a.components.y) == 1
    @test a[1] == Position(1, 2)

    a[1] = Position(3, 4)
    @test a[1] == Position(3, 4)
end
