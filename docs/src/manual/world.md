# The World

A [World](@ref world-api) is the central data store for any application that uses Ark.jl.
It manages [Entities](@ref), [Components](@ref) and [Resources](@ref),
and all these are always tied to a World.

Most applications will have exactly one world, but multiple worlds can exist at the same time.

## World creation

When creating a new world, all [Component types](@ref Components) that can exist in it must be specified.

```jldoctest; output = false
using Ark

struct Position
    x::Float64
    y::Float64
end

struct Velocity
    dx::Float64
    dy::Float64
end

world = World(Position, Velocity)
; # Suppress print output

# output

```

This may seem unusual, but it allows Ark to leverage Julia's compile-time programming
features for the best performance.

## World functionality

You will see that almost all methods in Ark's API take a World as their first argument.
These methods are explained in the following chapters.
