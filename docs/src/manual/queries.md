# Queries

Queries allow to select [Entities](@ref) that have a certain set of [Components](@ref) and to manipulate them.

Queries are the heart of every ECS and the main reason for its flexibility and performance.
In Ark, queries are blazing fast and should be used to write game or model logic where possible.
For cases where components of a articular entity are required, see section [Accessing components](@ref).

## Basic queries

By default, a [Query](@ref queries-api) lets you iterate over all entities that have the query's components,
and provides efficient access to these components.

Here, we are interested only in non-exclusive sets.
So the entities that are processed may have further components, but they are not of interest
for that particular piece of game or model logic.

```@meta
DocTestSetup = quote
    using Ark

    struct Position
        x::Float64
        y::Float64
    end
    struct Velocity
        dx::Float64
        dy::Float64
    end
    struct Health
        value::Float64
    end

    world = World(Position, Velocity, Health)
end
```

```jldoctest; output = false
for (entities, pos_column, vel_column) in @Query(world, (Position, Velocity))
    for i in eachindex(entities)
        pos = pos_column[i]
        vel = vel_column[i]
        pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
end

# output

```

## Advanced queries

### `with`

### `without`

### `optional`

## World lock
