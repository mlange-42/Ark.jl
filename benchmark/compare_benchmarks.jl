
include("util.jl")

data_current = read_bench_table("bench_current.csv")
data_main = read_bench_table("bench_main.csv")

result = compare_tables(data_main, data_current)
write_compare_table(result, "compare.csv")
markdown = table_to_markdown(result)

println(markdown)
