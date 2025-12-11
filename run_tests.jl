using Pkg

if length(ARGS) == 2
	Pkg.activate(ARGS[1])
	Pkg.test("Ark"; test_args=[ARGS[2],])
else
	Pkg.activate(".")
	Pkg.test("Ark"; test_args=ARGS)
end