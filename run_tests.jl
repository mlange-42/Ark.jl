using Pkg

if length(ARGS) == 2
	Pkg.activate(ARGS[1])
	Pkg.develop(path=".")
	Pkg.test("Ark"; test_args=[ARGS[2],], coverage=("CI" in keys(ENV)))
else
	Pkg.activate(".")
	Pkg.test("Ark"; test_args=ARGS)
end