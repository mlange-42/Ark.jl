
function setup_callback(n::Int)
    fns = Vector{Observer}()
    push!(fns, Observer(x::Int -> x * 2))
    push!(fns, Observer(x::Int -> x - 3))
    push!(fns, Observer(x::Int -> x * x))
    push!(fns, Observer(x::Int -> 5))

    return fns
end

function benchmark_callback(args, n)
    fns = args
    len = length(fns)
    sum = 0
    for i in 1:n
        sum += fns[i%len+1].fn(i)
    end
    return sum
end

SUITE["benchmark_callback n=1000"] = @be setup_callback(1000) benchmark_callback(_, 1000) seconds = SECONDS
