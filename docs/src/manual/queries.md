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
    new_entities!(world, 100, (Position(0,0), Velocity(0,0), Health(0)))
end
```

```jldoctest; output = false
for (entities, positions, velocities) in @Query(world, (Position, Velocity))
    @inbounds for i in eachindex(entities)
        pos = positions[i]
        vel = velocities[i]
        positions[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
    end
end

# output

```

Note the nested loop!
In the outer loop, the query iterates the [archetypes](@ref Architecture),
and for each one returns a vector of entities and the columns for the queried components.
In the inner loop, we iterate over the entities within the archetype and perform the actual logic.

Also not the last line in the inner loop. Here, we assign a new `Position` value to the current entity.
This is necessary as `Position` is immutable, which is the default and highly recommended.
See section [Component types](@ref) for details.

The `@inbounds` macro in front of the inner loop is optional, but it is safe to use here
and makes the iteration faster as it allows the compiler to skip bounds checks.

## Advanced queries

### `with`

### `without`

### `optional`

## World lock
