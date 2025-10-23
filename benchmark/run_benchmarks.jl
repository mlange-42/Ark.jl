
using Statistics

include("./benchmark/benchmarks.jl")

for x in sort(filter(x -> x[1] isa String, collect(pairs(SUITE.data))), by=(x->x[1]))
	x[1] isa Int && continue
	m = match(r"n=(\d+)", x[1])
	times = run(x[2]).times
	n = parse(Int, m.captures[1])
	times ./= n
	println("$(x[1]) time: $(mean(times)) ns")
end
