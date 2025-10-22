new = replace(String(read(Sys.ARGS[1])), ".../"=>" / ", "..."=>"")
old = replace(String(read(Sys.ARGS[2])), ".../"=>" / ", "..."=>"")

function combine((n,o))
    @show n o # Debug print statement, just in case.
    if count(==('|'), n) <= 3
        # @assert n == o
        return n
    end

    n_cols = split(n, '|')
    o_cols = split(o, '|')
    # @assert length(n_cols) == length(o_cols)
    # @assert isempty(first(n_cols))
    # @assert isempty(last(n_cols))
    # @assert isempty(first(o_cols))
    # @assert isempty(last(o_cols))
    # @assert n_cols[2] == o_cols[2]

    if all(isspace, n_cols[2]) || all(∈([':','-']), n_cols[2])
        # @assert n == o
        return n
    end

    o_data = strip(o_cols[end-1])
    n_data = strip(n_cols[end-1])
    n_cols[end-1] = if o_data == n_data * "," * n_data # If all three results are the same, only report one
        n_data
    else
        o_data * "," * n_data
    end
    join(n_cols, '|')
end

new2 = join(combine.(zip(split(new, '\n'), split(old, '\n'))), '\n')

open(Sys.ARGS[3], "w") do io
    write(io, new2)
end
