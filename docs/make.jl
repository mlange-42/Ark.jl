using Ark
using Documenter

DocMeta.setdocmeta!(Ark, :DocTestSetup, :(using Ark); recursive=true)

makedocs(;
    modules=[Ark],
    authors = "Martin Lange <martin_lange_@gmx.net>, Adriano Meligrana <adriano.meligrana@centai.eu>"
    sitename="Ark.jl",
    format=Documenter.HTML(;
        canonical="https://mlange-42.github.io/Ark.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md"
    ],
    warnonly = [:missing_docs],
)

deploydocs(;
    repo="github.com/mlange-42/Ark.jl",
    devbranch="main",
    push_preview = true,
)
