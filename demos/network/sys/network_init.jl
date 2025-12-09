
struct NetworkInit <: System
    distance::Int
end

NetworkInit(;
    distance::Int=25,
) = NetworkInit(distance)

function initialize!(s::NetworkInit, world::World)
    size = get_resource(world, WorldSize)

    rows = div(size.height, s.distance)
    cols = div(size.width, s.distance)
    offset_x = (size.width - (cols - 1) * s.distance) / 2
    offset_y = (size.height - (rows - 1) * s.distance) / 2
    jitter = s.distance / 4

    all_entities = Entity[]

    new_entities!(world, rows * cols, (Position, Node)) do (entities, positions, nodes)
        append!(all_entities, entities)
        for i in eachindex(positions)
            col, row = col_row(i, cols)
            positions[i] = Position(
                col * s.distance + offset_x + (rand() * 2 - 1) * jitter,
                row * s.distance + offset_y + (rand() * 2 - 1) * jitter,
            )
            nodes[i] = Node()
        end
    end

    edges = Tuple{Entity,Entity}[]
    for (entities,) in Query(world, (); with=(Position, Node))
        for i in eachindex(entities)
            entity = entities[i]
            col, row = col_row(i, cols)
            if col < cols - 1
                idx = index(col + 1, row, cols)
                push!(edges, (entity, all_entities[idx]))
            end
            if row < rows - 1
                idx = index(col, row + 1, cols)
                push!(edges, (entity, all_entities[idx]))
            end
        end
    end

    for (e1, e2) in edges
        p1, = get_components(world, e1, (Position,))
        p2, = get_components(world, e2, (Position,))
        dx = p1[1] - p2[1]
        dy = p1[2] - p2[2]
        edge = new_entity!(world, (Edge(e1, e2), EdgePosition(p1, p2), EdgeLength(sqrt(dx * dx + dy * dy))))

        n1, = get_components(world, e1, (Node,))
        n2, = get_components(world, e2, (Node,))
        push!(n1.edges, edge)
        push!(n2.edges, edge)
    end
end

function col_row(idx::Int, cols::Int)
    col = (idx - 1) % cols
    row = div((idx - 1), cols)
    return col, row
end

function index(col::Int, row::Int, cols::Int)
    return row * cols + col + 1
end
