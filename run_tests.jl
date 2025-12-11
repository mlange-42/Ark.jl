using Pkg
Pkg.activate(ARGS[1])
Pkg.test("Ark"; test_args=[ARGS[2],])
