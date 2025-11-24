
struct TravelerInit <: System
    count::Int
end

TravelerInit(;
    count::Int=1000,
) = TravelerInit(count)

function initialize!(s::TravelerInit, world::World)
    edges = Tuple{Entity,EdgePosition,EdgeLength}[]

    for (entities, positions, lengths) in Query(world, (EdgePosition, EdgeLength))
        append!(edges, zip(entities, positions, lengths))
    end

    for (_, travelers, positions, colors) in new_entities!(world, s.count, (Traveler, Position, Color))
        for i in eachindex(travelers)
            edge, edge_pos, edge_len = rand(edges)
            pos = rand() * edge_len.length
            fwd = rand(Bool)
            travelers[i] = Traveler(edge, pos, fwd)
            positions[i] = position(pos, fwd, edge_pos, edge_len)
            colors[i] = Color(HSL(rand() * 360, 0.5 + rand() * 0.3, 0.4 + rand() * 0.3))
        end
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
