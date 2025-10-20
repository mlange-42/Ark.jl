using Ark
using Test

@testset "_Graph functionality" begin
    # Create a graph
    graph = _Graph()
    @test length(graph.nodes) == 1

    # Create a mutable mask and set a bit
    mask = _MutableMask()
    _set_bit!(mask, UInt8(3))

    # Test _find_or_create: should create a new node
    node = _find_or_create(graph, mask)
    @test node.mask == _Mask(mask)
    @test node.archetype == typemax(UInt32)
    @test length(graph.nodes) == 2

    # Test _find_or_create again: should return existing node
    node2 = _find_or_create(graph, mask)
    @test node2 === node
    @test length(graph.nodes) == 2  # no new node added

    # Test _find_node: add and remove components
    start = graph.nodes[1]
    add = (UInt8(5),)
    remove = ()

    node3 = _find_node(graph, start, add, remove)
    @test node3 !== start
    @test _get_bit(node3.mask, UInt8(5))

    # Now test removing component 5
    node4 = _find_node(graph, node3, (), (UInt8(5),))
    @test node4 === start

    # Test error on removing nonexistent component
    err = try
        _find_node(graph, start, (), (UInt8(7),))
        false
    catch e
        isa(e, ErrorException)
    end
    @test err

    # Test error on adding duplicate component
    err2 = try
        _find_node(graph, node3, (UInt8(5),), ())
        false
    catch e
        isa(e, ErrorException)
    end
    @test err2
end