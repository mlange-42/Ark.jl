using Ark
using Documenter

DocMeta.setdocmeta!(Ark, :DocTestSetup, :(using Ark); recursive=true)

doctest(Ark)

makedocs(;
    modules=[Ark],
    sitename="Ark.jl",
    authors="Martin Lange <martin_lange_@gmx.net>, Adriano Meligrana <adriano.meligrana@centai.eu>",
    format=Documenter.HTML(;
        description="Ark.jl is an archetype-based entity component system (ECS) for Julia.",
        canonical="https://mlange-42.github.io/Ark.jl/dev",
        edit_link="main",
        prettyurls=false,
        sidebar_sitename=false,
        assets=["assets/favicon.ico", "assets/custom.css"],
    ),
    pages=[
        "Home" => "index.md",
        "Manual" => [
            "manual/quickstart.md",
            "manual/world.md",
            "manual/entities.md",
            "manual/components.md",
            "manual/queries.md",
            "manual/systems.md",
            "manual/resources.md",
            "manual/architecture.md",
        ],
        "Public API" => "api.md",
        "Benchmarks" => "benchmarks.md"
    ],
    warnonly=false,
)

deploydocs(;
    repo="github.com/mlange-42/Ark.jl.git",
    versions=[
        "stable" => "v^",
        "dev" => "main",
    ],
)
