
include("util.jl")

data_current = [
    read_bench_table("bench_current_1.csv")
    read_bench_table("bench_current_2.csv")
    read_bench_table("bench_current_3.csv")
]
data_main = [
    read_bench_table("bench_main_1.csv")
    read_bench_table("bench_main_2.csv")
    read_bench_table("bench_main_3.csv")
]

result = compare_multi_tables(data_main, data_current)

csv = table_to_csv(result,)
write("compare.csv", csv)

html = table_to_html(result)
write("compare.html", html)

markdown = table_to_markdown(result)
println(markdown)
