# Event system

Ark provides an event system with observers that allow an application to react on events,
such as adding and removing components and entities.

Observers can [filter](@ref Filters) for the events they are interested in, in several ways.
A callback function is executed for the affected entity whenever an observer's filter matches.

In addition to built-in lifecycle events like `OnCreateEntity` or `OnAddComponents`,
Ark supports [custom event types](@ref custom-events) that enable domain-specific triggers.
These events can be emitted manually and observed with the same filtering and callback mechanisms,
making them ideal for modeling interactions such as user input, synchronization, or game logic.

Observers are lightweight, composable, and follow the same declarative patterns as Ark’s [query](@ref Queries) system.
They provide fine-grained control over when and how logic is executed.
This design encourages a declarative, data-driven approach while maintaining performance and flexibility.

## Example

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

    world = World(Position, Velocity)
end
```

```jldoctest; output=false
@observe!(world, OnAddComponents, (Position, Velocity)) do entity
    pos, vel = @get_components(world, entity, (Position, Velocity))
    println(pos)
    println(vel)
end

entity = new_entity!(world, ())
add_components!(world, entity, (Position(0, 0), Velocity(1, 1)))

# output

Position(0.0, 0.0)
Velocity(1.0, 1.0)
```

## Event types

## Combining multiple types

## Filters

## Event timing

## [Custom events](@id custom-events)
