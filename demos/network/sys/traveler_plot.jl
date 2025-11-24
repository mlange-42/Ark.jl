
struct TravelerPlot <: System
end

function update!(s::TravelerPlot, world::World)
    data = get_resource(world, PlotData)
    traveler_data = data.travelers[]

    resize!(traveler_data, 0)

    for (_, positions) in Query(world, (Position,); with=(Traveler,))
        append!(traveler_data, positions)
    end

    notify(data.travelers)
end
