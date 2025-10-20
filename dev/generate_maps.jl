using Mustache

println("generating maps")

template = read("dev/templates/map.jl.template", String)

items = []
for i = 1:3
    types = [Dict("n" => idx, "upper" => string(Char(c)), "lower" => string(lowercase(Char(c)))) for (idx, c) in enumerate('A':'A'+i-1)]
    joined = join([string(Char(c)) for c in 'A':'A'+i-1], ",")
    tuple = join(fill("UInt8", i), ",")
    args = join([string(d["lower"], "::", d["upper"]) for d in types], ", ")
    values = join([d["lower"] for d in types], ", ")
    item = Dict(
        "N" => i,
        "types" => types,
        "joined" => joined,
        "tuple" => tuple,
        "args" => args,
        "values" => values,
    )

    push!(items, item)
end

data = Dict("items" => items)

println(render(template, data))
