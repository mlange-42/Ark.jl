
@testset "_Graph functionality" begin
    # Create a graph
    graph = _Graph{1}()
    @test length(graph.nodes) == 1

    # Create a mutable mask and set a bit
    mask = _MutableMask{1}()
    _set_bit!(mask, 3)

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
    start = first(graph.nodes)[2]
    add = (5,)
    remove = ()

    node3 = _find_node(graph, start, add, remove)
    @test node3 !== start
    @test _get_bit(node3.mask, 5)

    node4 = _find_node(graph, node3, (), (5,))
    @test node4 === start

    # Test error on removing nonexistent component
    @test_throws(
        "ArgumentError: entity does not have component to remove",
        _find_node(graph, start, (), (7,))
    )

    # Test error on adding duplicate component
    @test_throws(
        "ArgumentError: entity already has component to add, or it was added twice",
        _find_node(graph, node3, (5,), ())
    )

    # Test add and remove same
    @test_throws(
        "ArgumentError: component added and removed in the same exchange operation",
        _find_node(graph, node3, (5,), (5,))
    )
end
