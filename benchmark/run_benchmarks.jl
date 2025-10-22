
# this needs to be run from the ./Ark folder

using Pkg

if !("AirspeedVelocity" in keys(Pkg.project().dependencies))
    Pkg.add("AirspeedVelocity"); Pkg.build("AirspeedVelocity")
end

devbranch = readchomp(`git rev-parse --abbrev-ref HEAD`)

run(`$(joinpath(homedir(), ".julia/bin/benchpkg")) 
	--add https://github.com/LilithHafner/ChairmarksForAirspeedVelocity.jl 
	--rev $devbranch 
	--bench-on $devbranch`) # use --rev main, $devbranch to benchmark againt main