
@testset "FieldSubArray basic functionality" begin
    arr = [Position(1, 1), Position(2, 2), Position(3, 3)]
    v = view(arr, :)
    xs = _new_field_subarray(v, Val(:x))
    ys = _new_field_subarray(v, Val(:y))

    @test xs[1] == 1
    @test xs[2] == 2

    for (i, x) in enumerate(xs)
        @test x == i
    end

    xs[1] = 99
    xs[2] = 100
    @test xs[1] == 99
    @test xs[2] == 100

    @test length(xs) == 3
    @test size(xs) == (3,)
    @test eachindex(xs) == 1:3

    @test Base.firstindex(xs) == 1
    @test Base.lastindex(xs) == 3

    @test Base.eltype(typeof(xs)) == Float64
    @test Base.IndexStyle(typeof(xs)) == IndexLinear()

    xs .+= ys
    @test xs[1] == 100
    @test xs[2] == 102

    sum = collect(xs .+ ys)
    @test sum[1] == 101
    @test sum[2] == 104
end

@testset "FieldsView basic functionality" begin
    @test_throws "non-isbits type NoIsBits not supported by FieldsView" FieldsView(
        view([NoIsBits([]), NoIsBits([])], :),
    )

    arr = [Position(1, 1), Position(2, 2), Position(3, 3)]

    v = FieldsView(view(arr, :))

    count = 0
    for (i, p) in enumerate(v)
        @test p == Position(i, i)
        count += 1
    end
    for p in v
        @test p isa Position
        count += 1
    end
    @test count == 6

    @test iterate(v, 1) == (Position(1, 1), (1, nothing))
    @test iterate(v, 2) == (Position(2, 2), (2, nothing))
    @test_throws BoundsError iterate(v, 7)

    v[3] = Position(99, 99)
    @test v[3] == Position(99, 99)

    xs = v.x
    @test xs[1] == 1
    @test xs[2] == 2

    @test length(v) == 3
    @test size(v) == (3,)
    @test eachindex(v) == 1:3

    @test Base.firstindex(v) == 1
    @test Base.lastindex(v) == 3

    @test Base.eltype(FieldsView{Position}) == Position
    @test Base.IndexStyle(FieldsView{Position}) == IndexLinear()
end
