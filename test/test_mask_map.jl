
@testset "_Mask_Map init" begin
    d = _Mask_Map{1,Int}()
    @test length(d) == 0

    d2 = _Mask_Map{1,Float64}(5)
    @test length(d2.keys) == 8
    @test d2.max_load == floor(Int, 8 * _LOAD_FACTOR)
end

@testset "_Mask_Map basics" begin
    d = _Mask_Map{1,Int}(16)
    key1 = _Mask{1}((0x123456789ABC,))
    key2 = _Mask{1}((0x987654321FED,))

    # Test inserting a new value
    val1 = Base.get!(() -> 100, d, key1)
    @test val1 == 100
    @test length(d) == 1

    # Test retrieving existing value via get!
    val1_existing = Base.get!(() -> 500, d, key1)
    @test val1_existing == 100
    @test length(d) == 1

    # Test inserting another key
    val2 = Base.get!(() -> 200, d, key2)
    @test val2 == 200
    @test length(d) == 2
end

@testset "_Mask_Map getindex and get" begin
    d = _Mask_Map{1,String}(16)
    k1 = _Mask{1}((UInt64(1),))
    Base.get!(() -> "Value1", d, k1)

    # Test getindex
    @test d[k1] == "Value1"

    # Test error for missing key
    k_missing = _Mask{1}((UInt64(999),))
    @test_throws KeyError d[k_missing]

    # Test get (with default function)
    @test Base.get(() -> "Default", d, k1) == "Value1"
    @test Base.get(() -> "Default", d, k_missing) == "Default"
end

@testset "_Mask_Map resizing" begin
    initial_size = 4
    d = _Mask_Map{1,Int}(initial_size)

    # capacity is 4, max_load is 3 (4 * _LOAD_FACTOR=0.75)
    # reach max_load
    k1 = _Mask{1}((UInt64(1),));
    Base.get!(() -> 1, d, k1)
    k2 = _Mask{1}((UInt64(2),));
    Base.get!(() -> 2, d, k2)
    k3 = _Mask{1}((UInt64(3),));
    Base.get!(() -> 3, d, k3)

    @test length(d.keys) == 4
    @test d.count == 3

    # this should trigger resizing
    k4 = _Mask{1}((UInt64(4),))
    Base.get!(() -> 4, d, k4)

    # verify resizing happened
    @test length(d.keys) == 8
    @test d.count == 4

    # verify all items are still accessible
    @test d[k1] == 1
    @test d[k2] == 2
    @test d[k3] == 3
    @test d[k4] == 4
end

@testset "_Mask_Map get!" begin
    d = _Mask_Map{1,Int}(8)

    keys = [_Mask{1}((UInt64(i),)) for i in 1:6]

    for (i, k) in enumerate(keys)
        Base.get!(() -> i, d, k)
    end

    @test length(d) == 6

    # verify all are retrievable
    for (i, k) in enumerate(keys)
        @test d[k] == i
    end
end
