
function setup_callback(n::Int)
    fns = Vector{Observer}()
    push!(fns, Observer(entity -> is_zero(entity), OnCreateEntity))
    push!(fns, Observer(entity -> is_zero(entity), OnCreateEntity))
    push!(fns, Observer(entity -> is_zero(entity), OnCreateEntity))

    return fns
end

function benchmark_callback(args, n)
    fns = args
    len = length(fns)
    for i in 1:n
        fns[i%len+1]._fn(zero_entity)
    end
end

SUITE["benchmark_callback n=1000"] = @be setup_callback(1000) benchmark_callback(_, 1000) seconds = SECONDS
