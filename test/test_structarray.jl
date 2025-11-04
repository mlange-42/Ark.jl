
@testset "StructArray basic functionality" begin
    a = _StructArray(Position)

    @test isa(a.x, Vector{Float64})
    @test isa(a.y, Vector{Float64})
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
end

@testset "StructArray iteration" begin
    a = _StructArray(Position)

    resize!(a, 10)
    @test length(a) == 10

    for i in 1:10
        a[i] = Position(i, i)
    end

    count = 0
    for i in eachindex(a)
        @test a[i] == Position(i, i)
        count += 1
    end
    @test count == 10

    for pos in a
        @test isa(pos, Position)
    end
    for (i, pos) in enumerate(a)
        @test a[i] == Position(i, i)
    end
end

@testset "StructArray misc functions" begin
    a = _StructArray(Position)
    resize!(a, 10)

    @test Base.firstindex(a) == 1
    @test Base.lastindex(a) == 10

    @test Base.eltype(_StructArray{Position}) == Position
    @test Base.IndexStyle(_StructArray{Position}) == IndexLinear()
end

@testset "StructArray no fields" begin
    a = _StructArray(LabelComponent)

    push!(a, LabelComponent())
    @test length(a) == 1
    a[1] = LabelComponent()
end

@testset "StructArray unwrap" begin
    a = _StructArray(Position)

    x, y = a.components
    @test isa(x, Vector{Float64})
    @test isa(y, Vector{Float64})
end

@testset "StructArray type" begin
    tp = _StructArray_type(Position)
    @test tp == _StructArray{Position,@NamedTuple{x::Vector{Float64}, y::Vector{Float64}},2}
end
