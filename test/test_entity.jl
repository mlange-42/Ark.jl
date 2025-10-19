using Ark
using Test

include("../src/entity.jl")

@testset "_EntityPool constructor" begin
    initialCap = UInt32(10)
    reserved = UInt32(2)
    pool = Ark._EntityPool(initialCap, reserved)

    @test isa(pool, Ark._EntityPool)
    @test length(pool.entities) == reserved
    @test all(e -> e._gen == typemax(UInt32), pool.entities)
    @test pool.next == 0
    @test pool.available == 0
    @test pool.reserved == reserved
end
