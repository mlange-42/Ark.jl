# Ark.jl

[![Build Status](https://github.com/mlange-42/Ark.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mlange-42/Ark.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/mlange-42/Ark.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/mlange-42/Ark.jl)

Ark.jl is an archetype-based [Entity Component System](https://en.wikipedia.org/wiki/Entity_component_system) (ECS) for [Julia](https://julialang.org/).
It is a port of the Go ECS [Ark](https://github.com/mlange-42/ark).

⚠️ Ark.jl is still early work in progress! ⚠️

## Usage

```julia
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

# Create a world
world = World()

# Create a component mapper
map = Map2{Position,Velocity}(world)

for i in 1:1000
    # Create an entity with components
    entity = new_entity!(map, Position(i, i * 2), Velocity(1, 1))
    # Access components of an entity
    pos, vel = map[entity]
end

# Create a query
query = Query2{Position,Velocity}(world)

# Time loop
for i in 1:10
    # Iterate the query (archetypes)
    for _ in query
        # Get component columns of the current archetype
        pos_column, vel_column = query[]
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
```
