
function direction_to_rotation(v::Point2f)
    return atan(v[2], v[1])
end

function rotation_to_direction(a::Float64, v::Float64)
    return v * cos(a), v * sin(a)
end

function distance_sq(a::Point2f, b::Point2f)
    dx = a[1] - b[1]
    dy = a[2] - b[2]
    return dx * dx + dy * dy
end
