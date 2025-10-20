# Ark.jl

[![Build Status](https://github.com/mlange-42/Ark.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mlange-42/Ark.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/mlange-42/Ark.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/mlange-42/Ark.jl)

Ark.jl is an archetype-based [Entity Component System](https://en.wikipedia.org/wiki/Entity_component_system) (ECS) for [Julia](https://julialang.org/).
It is a port of the Go ECS [Ark](https://github.com/mlange-42/ark).

⚠️ Ark.jl is still early work in progress! ⚠️

## Usage

```julia
struct Position
    x::Float64
    y::Float64
end

struct Velocity
    dx::Float64
    dy::Float64
end

world = World()

m = Map2{Position,Velocity}(world)
for i in 1:1000
    new_entity!(m, Position(i, i * 2), Velocity(1, 1))
end

query = Query2{Position,Velocity}(world)
for i in 1:10
    for _ in query
        pos_column, vol_column = query[]
        for i in eachindex(pos_column)
            pos = pos_column[i]
            vel = vol_column[i]
            pos = Position(pos.x + vel.dx, pos.y + vel.dy)
            pos_column[i] = pos
        end
    end
end
```
