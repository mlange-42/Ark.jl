
struct Position
    x::Float64
    y::Float64
end

struct Velocity
    dx::Float64
    dy::Float64
end

function print_result(result, entities)
    if full_output
        @printf "\nEntities: %7d, mean: %7.4f\n" entities (time(mean(result)) / entities)
        display(result)
    else
        @printf "Entities: %7d, mean: %7.4f\n" entities (time(mean(result)) / entities)
    end
end
