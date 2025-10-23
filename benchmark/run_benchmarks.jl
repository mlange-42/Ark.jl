using Statistics
using Printf

include("./benchmark/benchmarks.jl")

for x in sort(filter(x -> x[1] isa String, collect(pairs(SUITE.data))), by=(x->x[1]))
	x[1] isa Int && continue
	m = match(r"n=(\d+)", x[1])
	times = run(x[2]).times
	n = parse(Int, m.captures[1])
	times ./= n
	@printf("%-40s time: %10.2f ns\n", x[1], mean(times))
end
