
using Pkg

if !("AirspeedVelocity" in keys(Pkg.project().dependencies))
    Pkg.add("AirspeedVelocity"); Pkg.build("AirspeedVelocity")
end

~/.julia/bin/benchpkg --add https://github.com/LilithHafner/ChairmarksForAirspeedVelocity.jl --rev dirty,main
