# Event system

Ark provides an event system with observers that allow an application to react on events,
such as adding and removing components and entities.

Observers can [filter](@ref Filters) for the events they are interested in, in several ways.
A callback function is executed for the affected entity whenever an observer's filter matches.

In addition to built-in lifecycle events like `OnCreateEntity` or `OnAddComponents`,
Ark supports [custom event types](@ref custom-events) that enable domain-specific triggers.
These events can be emitted manually and observed with the same filtering and callback mechanisms,
making them ideal for modeling interactions such as user input, synchronization, or game logic.

Observers are lightweight, composable, and follow the same declarative patterns as
Ark’s [query](@ref Queries) system.
They provide fine-grained control over when and how logic is executed.
This design encourages a declarative, data-driven approach while maintaining performance and flexibility.

## Example

Use [@observe!](@ref) to observe for events:

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
    struct Altitude
        z::Float64
    end

    world = World(Position, Velocity, Altitude)
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

Observers are specific for different event types, and each observer can react only to one type.
See [below](@ref combining-types) for how to react on multiple different types.

- **OnCreateEntity**: Emitted after a new entity is created.  
- **OnRemoveEntity**: Emitted before an entity is removed.
- **OnAddComponents**: Emitted after components are added to an existing entity.
- **OnRemoveComponents**: Emitted before components are removed from an entity.

If multiple components are added/removed for an entity,
one event is emitted for the entire operation.

## [Combining multiple types](@id combining-types)

Observers can be combined to react to multiple event types in a single callback function.
Below is a combination of observers to react on component addition as well as removal.
The callback is set up to be able to distinguish between these event types (if needed).

```jldoctest; output=false
fn = (event::EventType, entity::Entity) -> begin
    if event == OnAddComponents
        println("Position added")
    elseif event == OnRemoveComponents
        println("Position removed")
    end
end

@observe!(world, OnAddComponents, (Position,)) do entity
    fn(OnAddComponents, entity)
end
 @observe!(world, OnRemoveComponents, (Position,)) do entity
    fn(OnRemoveComponents, entity)
end
; # suppress print output

# output

```

## Filters

Observers only trigger when all specified components (last non-keyword argument)
are affected in a single operation.
For example, if an observer watches `Position` and `Velocity`,
both must be added or removed together for the observer to activate.

Further, events can be filtered by the composition of the affected entity via
the keyword arguments `with`, `without` and `exclusive`, just like [queries](@ref Queries).

For entity creation and removal, only the keyword arguments can be used.

**Examples** (leaving out observer registration):

An observer that is triggered when a `Position` component is added to an existing entity:

```jldoctest; output=false
@observe!(world, OnAddComponents, (Position,)) do entity
    # ...
end
; # suppress print output

# output

```

An observer that is triggered when a `Position` component is added to an entity
that has `Velocity`, but not `Altitude` (or rather, had before the operation):

```jldoctest; output=false
@observe!(world, OnAddComponents, (Position,),
        with    = (Velocity,),
        without = (Altitude,)
    ) do entity
    # ...
end
; # suppress print output

# output

```

This observer is triggered when an entity with `Position` is created:

```jldoctest; output=false
@observe!(world, OnCreateEntity,
        with    = (Velocity,)
    ) do entity
    # ...
end
; # suppress print output

# output

```

This observer is triggered when an entity with `Position` as well as `Velocity` is created:

```jldoctest; output=false
@observe!(world, OnCreateEntity,
        with    = (Position, Velocity)
    ) do entity
    # ...
end
; # suppress print output

# output

```

An observer that is triggered when any entity is created, irrespective of its components:

```jldoctest; output=false
@observe!(world, OnCreateEntity) do entity
    # ...
end
; # suppress print output

# output

```

## Event timing

The time an event is emitted relative to the operation it is related to depends on the event's type.
The observer callbacks are executed immediately by any emitted event.

Events for entity creation and for adding or setting components are emitted after the operation.
Hence, the new or changed components can be inspected in the observer's callback.
If emitted from individual operations, the world is in an [unlocked](@ref world-lock) state when the callback is executed. Contrary, when emitted from a batch operation, the world is [locked](@ref world-lock).

Events for entity or component removal are emitted before the operation.
This way, the entity or component to be removed can be inspected in the observer's callback.
In this case, the world is [locked](@ref world-lock) when the callback is executed.

Note that observer order is undefined. Observers are not necessarily triggered
in the same order as they were registered.

## [Custom events](@id custom-events)
