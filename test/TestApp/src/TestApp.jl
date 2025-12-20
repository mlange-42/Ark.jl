module TestApp

using Ark

include("components.jl")
include("query.jl")
include("relations.jl")

function julia_main()::Cint
    println("test_query")
    test_query()

    println("test_relations")
    test_relations()

    return 0
end

end
