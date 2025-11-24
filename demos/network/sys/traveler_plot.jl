
struct TravelerPlot <: System
end

function update!(s::TravelerPlot, world::World)
    data = get_resource(world, PlotData)
    traveler_data = data.travelers[]
    color_data = data.colors[]

    resize!(traveler_data, 0)
    resize!(color_data, 0)

    for (_, positions, colors) in Query(world, (Position, Color); with=(Traveler,))
        append!(traveler_data, positions)
        append!(color_data, colors)
    end

    notify(data.travelers)
    notify(data.colors)
end
