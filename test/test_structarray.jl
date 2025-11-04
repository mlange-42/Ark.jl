
@testset "StructArray basic functionality" begin
    a = _StructArray(Position)

    @test isa(a.components.x, Vector{Float64})
    @test isa(a.components.y, Vector{Float64})
end
