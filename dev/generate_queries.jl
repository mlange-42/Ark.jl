using Mustache
using JuliaFormatter

println("generating queries")

template = read("dev/templates/query.jl.template", String)

items = []
for i = 1:8
    types = [Dict("n" => idx, "upper" => string(Char(c)), "lower" => string(lowercase(Char(c)))) for (idx, c) in enumerate('A':'A'+i-1)]
    joined = join([string(Char(c)) for c in 'A':'A'+i-1], ",")
    tuple = join(fill("UInt8", i), ",")
    args = join([string(d["lower"], "::", d["upper"]) for d in types], ", ")
    values = join([d["lower"] for d in types], ", ")
    columns = join([string("Column{", d["upper"], "}") for d in types], ", ")
    item = Dict(
        "N" => i,
        "types" => types,
        "joined" => joined,
        "tuple" => tuple,
        "args" => args,
        "values" => values,
        "columns" => columns,
    )

    push!(items, item)
end

data = Dict("items" => items)

write("src/query_gen.jl", render(template, data))
format_file("src/query_gen.jl")
