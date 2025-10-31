# Entities

[Entities](@ref entities-api) are the "game objects" or "model entities" in applications that use Ark.
In effect, an entity is just an ID that can be associated with [Components](@ref),
which contain the entity's properties or state variables.

## [Creating entities](@id creating-entities)

An entity can only exist in a [World](@ref), and thus can only be created through a World.

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

Here, we use [new_entity!](@ref) to create an entity with a `Position` and a `Velocity` components.
Note that component values are passed as a tuple!

```jldoctest; output = false
entity = new_entity!(world, (
    Position(100, 100),
    Velocity(0, 0),
))

# output

Entity(0x00000002, 0x00000000)
```

Components can be added to and removed from the entity later. This is described in the [next chapter](@ref Components).

Often, multiple entities with the same same set of components are created at the same time.
For that sake, Ark provides batch entity creation, which is much faster than creating entities one by one. There are different ways to create entities in batches:

From **default component values** using [new_entities!](@ref new_entities!(::World, ::Int, ::Tuple; ::Bool)). Here, we create 100 entities, all with the same `Position` and `Velocity`:

```jldoctest; output = false
new_entities!(world, 100, (
    Position(100, 100),
    Velocity(0, 0),
))

# output

```

This may be sufficient in some use cases, but most often we will use a second approach:

From **component types** with subsequent manual initialization using the macro [@new_entities!](@ref):

```jldoctest; output = false
for (entities, positions, velocities) in @new_entities!(world, 100, (Position, Velocity))
    for i in eachindex(entities)
        positions[i] = Position(i, i)
        velocities[i] = Velocity(0, 0)
    end
end

# output

```

The nested loop shown here will be explained in detail in the chapter on [Queries](@ref),
which work in the same way at the [Batch](@ref) iterator that is returned from [@new_entities!](@ref)
and that is used here.

Note that with the second approach, all components of all entities should be set as they are otherwise uninitialized.

## Removing entities

Removing an entity from the World is as easy as this:

```@meta
DocTestSetup = quote
    using Ark
    world = World()
    entity = new_entity!(world, ())
end
```

```jldoctest; output = false
remove_entity!(world, entity)

# output

```

## Alive status

Entities can be safely stored, e.g. in the [Components](@ref) of other entities to represent relationships. However, as they may have been removed from the world elsewhere,
it may be necessary to check whether an entity is still alive:

```@meta
DocTestSetup = quote
    using Ark
    world = World()
    entity = new_entity!(world, ())
end
```

```jldoctest entities; output = false
if is_alive(world, entity)
    # ...
end

# output

```

## Zero entity

There is a reserved [zero_entity](@ref) that can be used as a placeholder for "no entity".
The zero entity is never alive.
the function [is_zero](@ref) can be used to determine whether an entity is the zero entity:

```jldoctest entities; output = false
if is_zero(entity)
    # ...
end

# output

```
