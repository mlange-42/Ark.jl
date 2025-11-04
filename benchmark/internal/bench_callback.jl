
function setup_callback(n::Int)
    fns = Vector{Observer}()
    push!(fns, Observer(entity -> nothing, OnCreateEntity))
    push!(fns, Observer(entity -> nothing, OnCreateEntity))
    push!(fns, Observer(entity -> nothing, OnCreateEntity))

    return fns, [i%length(fns)+1 for i in 1:n]
end

function benchmark_callback(args, n)
    fns, ids = args
    @inbounds for i in ids
        fns[i]._fn(zero_entity)
    end
end

SUITE["benchmark_callback n=1000"] = @be setup_callback(1000) benchmark_callback(_, 1000) seconds = SECONDS
