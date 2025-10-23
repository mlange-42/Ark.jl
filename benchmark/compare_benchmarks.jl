
include("util.jl")

data_current = read_bench_table("bench_current.csv")
data_main = read_bench_table("bench_main.csv")

result = compare_tables(data_main, data_current)

csv = table_to_csv(result,)
write("compare.csv", csv)

html = table_to_html(result)
write("compare.html", html)

markdown = table_to_markdown(result)
println(markdown)
