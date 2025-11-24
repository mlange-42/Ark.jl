
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

    for (entities, positions) in new_entities!(world, rows * cols, (Position,))
        append!(all_entities, entities)
        for i in eachindex(positions)
            col, row = col_row(i, cols)
            positions[i] = Position(
                col * s.distance + offset_x + (rand() * 2 - 1) * jitter,
                row * s.distance + offset_y + (rand() * 2 - 1) * jitter,
            )
        end
    end

    edges = Tuple{Entity,Entity}[]
    for (entities,) in Query(world, (); with=(Position,))
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
        new_entity!(world, (Edge(e1, e2),))
    end
end

function col_row(idx::Int, cols::Int)
    col = (idx - 1) % cols
    row = div((idx - 1), cols)
    return col, row
end

function index(col::Int, row::Int, cols::Int)
    return row * cols + col
end
