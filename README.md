<div align="center" width="100%">

[![Ark.jl (logo)](https://github.com/user-attachments/assets/efd131c8-cadf-434e-9994-c02f5914f2fa)](https://github.com/mlange-42/ark.jl)
[![Build Status](https://github.com/mlange-42/Ark.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mlange-42/Ark.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/mlange-42/Ark.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/mlange-42/Ark.jl)
[![GitHub](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/mlange-42/ark)
[![MIT license](https://img.shields.io/badge/MIT-brightgreen?label=license)](https://github.com/mlange-42/ark/blob/main/LICENSE-MIT)
[![Apache 2.0 license](https://img.shields.io/badge/Apache%202.0-brightgreen?label=license)](https://github.com/mlange-42/ark/blob/main/LICENSE-APACHE)

Ark.jl is an archetype-based [Entity Component System](https://en.wikipedia.org/wiki/Entity_component_system) (ECS) for [Julia](https://julialang.org/).
It is a port of the Go ECS [Ark](https://github.com/mlange-42/ark).

⚠️ Ark.jl is still early work in progress! ⚠️

&mdash;&mdash;

[Features](#features) &nbsp; &bull; &nbsp; [Installation](#installation) &nbsp; &bull; &nbsp; [Usage](#usage)
</div>

## Features

- [x] Designed for performance ~~and highly optimized~~ (ongoing).
- [x] Well-documented, type-safe API.
- [ ] [Entity relationships](https://mlange-42.github.io/ark/relations/) as a first-class feature.
- [ ] Extensible [event system](https://mlange-42.github.io/ark/events/) with filtering and custom event types.
- [ ] Fast [batch operations](https://mlange-42.github.io/ark/batch/) for mass manipulation.
- [x] No systems. Just queries. Use your own structure.
- [x] Zero [dependencies](https://github.com/mlange-42/Ark.jl/blob/main/Project.toml), ~~100% [test coverage](https://app.codecov.io/github/mlange-42/ark.jl).~~

## Installation

Ark.jl is not yet released. For now, run this in your project to use it:

```julia
using Pkg
Pkg.add(url="https://github.com/mlange-42/ark.jl")
```

## Usage

Here is the classical Position/Velocity example that every ECS shows in the docs.

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
map = Map(world, (Position,Velocity))

for i in 1:1000
    # Create an entity with components
    entity = new_entity!(map, Position(i, i * 2), Velocity(1, 1))
    # Access components of an entity (just to show...)
    pos, vel = map[entity]
end

# Create a query
query = Query(world, (Position, Velocity))

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

## License

Ark.jl and all its sources and documentation are distributed under the [MIT license](./LICENSE-MIT) and the [Apache 2.0 license](./LICENSE-APACHE), as your options.
