module TestApp

using Ark

include("components.jl")
include("query.jl")

function julia_main()::Cint
    println("test_query")
    test_query()

    return 0
end

end
