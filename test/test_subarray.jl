
@testset "FieldView basic functionality" begin
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

    @test similar(xs, Float64, (3,)) isa Vector{Float64}
    @test parent(xs) == xs._data
    @test pointer(xs) == pointer(xs._data)
    @test pointer(xs, 1) == pointer(xs._data, 1)
    @test strides(xs) == strides(xs._data)
end

@testset "FieldsView basic functionality" begin
    @test_throws "non-isbits type NoIsBits not supported by FieldsView" _new_fields_view(
        view([NoIsBits([]), NoIsBits([])], :),
    )

    arr = [Position(1, 1), Position(2, 2), Position(3, 3)]

    v = _new_fields_view(view(arr, :))

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

@testset "SubArray unpack" begin
    arr = [Position(1, 1), Position(2, 2), Position(3, 3)]

    v = view(arr, :)

    @test unpack(v) == v
end

@testset "FieldView show" begin
    vec = Vector{Position}()
    a = _new_fields_view(view(vec, :))
    @test string(a.x) == "0-element FieldView() with eltype Float64"

    vec = Vector{Position}()
    for i in 1:11
        push!(vec, Position(i, i))
    end
    a = _new_fields_view(view(vec, :))

    @test string(a.x) == "11-element FieldView() with eltype Float64
 [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0]
"

    vec = Vector{Position}()
    for i in 1:12
        push!(vec, Position(i, i))
    end
    a = _new_fields_view(view(vec, :))

    @test string(a.x) == "12-element FieldView() with eltype Float64
 [1.0, 2.0, 3.0, 4.0, 5.0, …, 8.0, 9.0, 10.0, 11.0, 12.0]
"
end

@testset "FieldsView show" begin
    vec = Vector{Position}()
    for i in 1:11
        push!(vec, Position(i, i))
    end
    a = _new_fields_view(view(vec, :))

    @test string(a) ==
          "11-element FieldsView(x::FieldView{Float64}, y::FieldView{Float64}) with eltype Position
 Position(1.0, 1.0)
 Position(2.0, 2.0)
 Position(3.0, 3.0)
 Position(4.0, 4.0)
 Position(5.0, 5.0)
 Position(6.0, 6.0)
 Position(7.0, 7.0)
 Position(8.0, 8.0)
 Position(9.0, 9.0)
 Position(10.0, 10.0)
 Position(11.0, 11.0)
"

    vec = Vector{Position}()
    for i in 1:12
        push!(vec, Position(i, i))
    end
    a = _new_fields_view(view(vec, :))

    @test string(a) ==
          "12-element FieldsView(x::FieldView{Float64}, y::FieldView{Float64}) with eltype Position
 Position(1.0, 1.0)
 Position(2.0, 2.0)
 Position(3.0, 3.0)
 Position(4.0, 4.0)
 Position(5.0, 5.0)
 ⋮
 Position(8.0, 8.0)
 Position(9.0, 9.0)
 Position(10.0, 10.0)
 Position(11.0, 11.0)
 Position(12.0, 12.0)
"
end
