using Ark
using Documenter

DocMeta.setdocmeta!(Ark, :DocTestSetup, :(using Ark); recursive=true)

doctest(Ark)

makedocs(;
    modules=[Ark],
    sitename="Ark.jl",
    authors="Martin Lange <martin_lange_@gmx.net>, Adriano Meligrana <adriano.meligrana@centai.eu>",
    format=Documenter.HTML(;
        canonical="https://mlange-42.github.io/Ark.jl",
        edit_link="main",
        prettyurls=false,
    ),
    pages=[
        "Home" => "./index.md",
        "API" => "./api.md"
    ],
    warnonly=[:missing_docs],
)
