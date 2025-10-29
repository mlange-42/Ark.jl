# Quickstart

This page shows how to install Ark.jl, and gives a minimal usage example.

Finally, it points into possible directions to continue.

## Installation

Ark.jl is not yet released. For now, run this in your project to use it:

```julia
using Pkg
Pkg.add(url="https://github.com/mlange-42/ark.jl")
```

## Example

Here is the classical Position/Velocity example that every ECS shows in the docs.

```jldoctest; output = false
using Ark

"""Position component"""
struct Position
    x::Float64
    y::Float64
end

"""Velocity component"""
struct Velocity
    dx::Float64
    dy::Float64
end

# Create a world with the required components
world = World(Position, Velocity)

for i in 1:1000
    # Create an entity with components
    entity = new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
end

# Time loop
for i in 1:10
    # Iterate a query (archetypes)
    for (entities, pos_column, vel_column) in @Query(world, (Position, Velocity))
        # Iterate entities in the current archetype
        for i in eachindex(pos_column)
            # Get components of the current entity
            pos = pos_column[i]
            vel = vel_column[i]
            # Update an (immutable) component
            pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
        end
    end
end

# output

```

## What's next?

If you ask **"What is ECS?"**, take a look at the great [**ECS FAQ**](https://github.com/SanderMertens/ecs-faq) by Sander Mertens, the author of the [Flecs](http://flecs.dev) ECS.

To learn how to use Ark.jl, read the following chapters,
browse the [API documentation](https://pkg.go.dev/github.com/mlange-42/ark),
or take a look at the [GitHub repository](https://github.com/mlange-42/Ark.jl).
