using Pkg
Pkg.activate("test")
Pkg.test("Ark"; test_args=ARGS)
