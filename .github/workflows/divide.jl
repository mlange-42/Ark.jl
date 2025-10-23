
using Pkg
Pkg.add("JSON")
using JSON

results_dir = ARGS[1]
json_files = filter(f -> endswith(f, ".json"), readdir(results_dir))

for file in json_files
	json_text = read(joinpath(results_dir, file), String) # I need to find branch somehow
	data = JSON.parse(json_text)
	for x in pairs(data["data"])
		m = match(r"n=(\d+)", x[1])
		if m != nothing 
		    n = parse(Int, m.captures[1])
		    x[2]["times"] ./= n
		end
	end
	open(joinpath(results_dir, file), "w") do f
	    JSON.print(f, data) 
	end
end
