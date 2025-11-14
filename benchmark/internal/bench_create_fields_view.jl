using Ark: _StructArray
using FieldViews

function setup_create_view_fields()
    vec = [Position(0, 0), Position(0, 0), Position(0, 0), Position(0, 0), Position(0, 0)]
    fv = FieldViewable(vec)
    return vec, fv
end

function benchmark_create_view_fields(args)
    vec, _ = args
    fv = FieldViewable(vec)
    return fv
end

SUITE["benchmark_create_view_fields n=1"] =
    @be setup_create_view_fields() benchmark_create_view_fields(_) seconds = SECONDS

function setup_create_view_vector()
    vec = [Position(0, 0), Position(0, 0), Position(0, 0), Position(0, 0), Position(0, 0)]
    v = view(vec, :)
    return vec, v
end

function benchmark_create_view_vector(args)
    vec, _ = args
    v = view(vec, :)
    return v
end

SUITE["benchmark_create_view_vector n=1"] =
    @be setup_create_view_vector() benchmark_create_view_vector(_) seconds = SECONDS

function setup_create_view_structarray()
    vec = _StructArray(Position)
    for _ in 1:5
        push!(vec, Position(0, 0))
    end
    v = view(vec, :)
    return vec, v
end

function benchmark_create_view_structarray(args)
    vec, _ = args
    v = view(vec, :)
    return v
end

SUITE["benchmark_create_view_structarray n=1"] =
    @be setup_create_view_structarray() benchmark_create_view_structarray(_) seconds = SECONDS
