
@testset "StructArray basic functionality" begin
    a = _StructArray(Position)

    @test isa(a.components.x, Vector{Float64})
    @test isa(a.components.y, Vector{Float64})

    push!(a, Position(1, 2))

    @test length(a) == 1
    @test size(a) == (1,)
    @test length(a.components.x) == 1
    @test length(a.components.y) == 1
    @test a[1] == Position(1, 2)

    a[1] = Position(3, 4)
    @test a[1] == Position(3, 4)

    push!(a, Position(5, 6))
    @test length(a) == 2

    pop!(a)
    @test length(a) == 1

    resize!(a, 10)
    @test length(a) == 10

    for i in 1:10
        a[i] = Position(i, i)
    end
    for i in 1:10
        @test a[i] == Position(i, i)
    end
end

@testset "StructArray no fields" begin
    a = _StructArray(LabelComponent)

    push!(a, LabelComponent())
    @test length(a) == 1
    a[1] = LabelComponent()
end
