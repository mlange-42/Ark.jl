using BenchmarkTools
using Ark
using ArgParse
using Printf

s = ArgParseSettings()
@add_arg_table s begin
    "--short"
    help = "Enable short output"
    action = :store_true
    "--seconds"
    help = "Time to run per benchmark"
    arg_type = Float64
    default = 1
end

args = parse_args(ARGS, s)

full_output = !args["short"]
seconds = args["seconds"]

include("BenchTypes.jl")

include("bench_query_posvel.jl")
include("bench_world_posvel.jl")
include("bench_world_get_1.jl")
include("bench_world_get_5.jl")
include("bench_map_posvel.jl")
include("bench_map_get_1.jl")
include("bench_map_get_5.jl")
include("bench_new_entity_1.jl")
include("bench_new_entity_5.jl")
include("bench_add_remove.jl")
