
# run with julia run_benchmarks.jl dev-branch-name
using Pkg

if !("AirspeedVelocity" in keys(Pkg.project().dependencies))
    Pkg.add("AirspeedVelocity"); Pkg.build("AirspeedVelocity")
end

devbranch = ARGS[1]
run(`$(joinpath(homedir(), ".julia/bin/benchpkg")) --add https://github.com/LilithHafner/ChairmarksForAirspeedVelocity.jl --rev main,$devbranch --bench-on $devbranch`)
