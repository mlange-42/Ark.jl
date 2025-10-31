include("util/compare.jl")

data_current = [read_bench_table("bench_current_$i.csv") for i in 1:3]
data_main = [read_bench_table("bench_main_$i.csv") for i in 1:3]

result = compare_multi_tables(data_main, data_current)

csv = table_to_csv(result)
write("compare.csv", csv)

html = table_to_html(result)
write("compare.html", html)

markdown = table_to_markdown(result)
println(markdown)
