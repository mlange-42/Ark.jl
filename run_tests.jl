using Pkg
Pkg.activate(".")
Pkg.test("Ark"; test_args=ARGS)
