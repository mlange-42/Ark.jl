
struct NetworkInit <: System
    count::Int
end

NetworkInit(;
    count::Int=100,
) = NetworkInit(count)

function initialize!(s::NetworkInit, world::World)
    size = get_resource(world, WorldSize)
end
