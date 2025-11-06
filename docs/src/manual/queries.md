# Queries

Queries allow to select [Entities](@ref) that have a certain set of [Components](@ref) and to manipulate them.

Queries are the heart of every ECS and the main reason for its flexibility and performance.
In Ark, queries are blazing fast and should be used to write the game or model logic where possible.
For cases where components of a particular entity are required, see section [Accessing components](@ref).

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

Query filters can be configured further, to include or exclude additional components.

### `with`

Queries provide an optional `with` argument that filters for additional components
that entities must have, but that are not used by the query.

```jldoctest; output = false
for (entities, positions, velocities) in @Query(world,
            (Position, Velocity);
            with=(Health,)
        )
    @inbounds for i in eachindex(entities)
        # ...
    end
end

# output

```

### `without`

The optional `without` argument allows to exclude entities that have certain components:

```jldoctest; output = false
for (entities, positions, velocities) in @Query(world,
            (Position, Velocity);
            without=(Health,)
        )
    @inbounds for i in eachindex(entities)
        # ...
    end
end

# output

```

### `exclusive`

The optional `exclusive` argument excludes entities that have any other then the query's components
and those specified by `with`. So it acts like an exhaustive `without`:

```jldoctest; output = false
for (entities, positions, velocities) in @Query(world,
            (Position, Velocity);
            exclusive=true
        )
    @inbounds for i in eachindex(entities)
        # ...
    end
end

# output

```

### `optional`

The optional `optional` argument makes components optional. 😉

Entities are included irrespective of presence of these components on them.
Note that, in contrast to the other arguments, this one is not related to additional components,
but refers to components of the query's "normal" components set.

Optional components are still included in the iterator's columns tuple,
but they are `nothing` if the current [archetype](@ref Architecture) does not have them.

```jldoctest; output = false
for (entities, positions, velocities) in @Query(world,
            (Position, Velocity);
            optional=(Velocity,)
        )
    has_velocity = velocities !== nothing
    @inbounds for i in eachindex(entities)
        # ...
    end
end

# output

```

Note that it is possible to branch already outside of the inner loop,
as all entities in an archetype either have a component or don't.

## Component field views

Individual fields of components can be accessed as vectors in queries, e.g. using [@unpack](@ref).
This is particularly useful for components that use the StructArray [storage modes](@ref component-storages),
as it allows for SIMD-accelerated vectorized operations.

```jldoctest; setup = :(using Ark), output = false
world = World(
    (Position, StructArrayComponent),
    (Velocity, StructArrayComponent),
)

# ...

for columns in Query(world, Val.((Position, Velocity)))
    @unpack entities, (x, y), (dx, sy) = columns
    @inbounds x .+= dx
    @inbounds y .+= dy
end

# output

```

However, when iterating components that use StructArray storage without unpacking individual fields,
there is a certain overhead and SIMD optimization may not be possible.

## [World lock](@id world-lock)

During query iteration, the World is locked for modifications like
entity creation and removal and component addition and removal.
This is necessary to prevent changes to the inner storage structure of the World
that would result in undefined behavior of the query.

If the necessity for these forbidden iteration arises,
the respective entities must be collected into a `Vector` to apply the
operations after query iteration has finished.

```jldoctest; output = false
# vector for entities to be removed from te world
to_remove = Entity[]

for (entities, positions) in @Query(world, (Position,))
    @inbounds for i in eachindex(entities)
        pos = positions[i]

        # collect entities for removal
        if pos.y < 0
            push!(to_remove, entities[i])
        end
    end
end

# actual removal
for entity in to_remove
    remove_entity!(world, entity)
end

# clear the vector for re-use
resize!(to_remove, 0)

# output

Entity[]
```

For the best performance, such a Vector should be stored persistently and re-used
to avoid repeated memory allocations.

The world is automatically unlocked when query iteration finishes.
When breaking out of a query loop, however, it must be unlocked by calling
[close!](@ref close!(::Query)) on the query.
