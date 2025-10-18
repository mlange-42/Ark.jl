using Ark
using Documenter

DocMeta.setdocmeta!(Ark, :DocTestSetup, :(using Ark); recursive=true)

makedocs(;
    modules=[Ark],
    authors="Martin Lange <martin_lange_@gmx.net>",
    sitename="Ark.jl",
    format=Documenter.HTML(;
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
