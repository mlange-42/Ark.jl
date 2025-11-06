using Ark: _new_fields_view

function setup_create_fieldsview()
    vec = [Position(0, 0), Position(0, 0), Position(0, 0), Position(0, 0), Position(0, 0)]
    v = view(vec, :)
    fv = _new_fields_view(v)
    return v, fv
end

function benchmark_create_fieldsview(args)
    v, _ = args
    b = UInt64(0)
    fv = _new_fields_view(v)
    return fv
end

SUITE["benchmark_create_fieldsview n=1"] =
    @be setup_create_fieldsview() benchmark_create_fieldsview(_) seconds = SECONDS
