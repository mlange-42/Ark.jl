
struct BoidsPlot <: System
end

function update!(s::BoidsPlot, world::World)
    data = get_resource(world, PlotData)
    pos_data = data.positions[]
    rot_data = data.rotations[]

    resize!(pos_data, 0)
    resize!(rot_data, 0)

    for (_, positions, rotations) in Query(world, (Position, Rotation))
        append!(pos_data, positions)
        append!(rot_data, rotations)
    end

    notify(data.positions)
    notify(data.rotations)
end
