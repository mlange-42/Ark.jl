
function normalize(dx::Float64, dy::Float64)
    len = sqrt(dx * dx + dy * dy)
    if len == 0
        return 0, 0, 0
    end
    return dx / len, dy / len, len
end
