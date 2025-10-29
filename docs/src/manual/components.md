# Components

Components contain the data associated to an [Entity](@ref Entities),
i.e. their properties or state variables.

## Component types

Components are distinguished by their type, and each entity can only have
one component of a certain type.

In Ark, any type can be used as a component.
However, it is highly recommended to use immutable types,
because all mutable objects are allocated on the heap in Julia,
which defeats Ark's claim of high performance.
Immutable types are disallowed by default, but can be enabled when constructing a [World](@ref)
by the optional argument `allow_mutable` of the [world constructor](@ref World(::Type...; ::Bool)).

## Accessing components

Although the majority of the logic in an application that uses Ark will be performed in [Queries](@ref),
it may be necessary to access components for a particular entity.
One or more components of an entity can be accessed via [@get_components](@ref):

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
    entity = new_entity!(world, (Position(0, 0), Velocity(0, 0)))
end
```

```jldoctest; output = false
(pos, vel) = @get_components(world, entity, (Position, Velocity))

# output

(Position(0.0, 0.0), Velocity(0.0, 0.0))
```

Similarly, the components of an entity can be overwritten by new values via [set_components!](@ref),
which is particularly useful for immutable components (which are the default):

```jldoctest; output = false
set_components!(world, entity, (Position(0, 0), Velocity(1,1)))

# output

```

## Adding and removing components

A feature that makes ECS particularly flexible and powerful is the ability to
add components to and remove them from entities at runtime.
This works similar to component access and can be done via [add_components!](@ref) and [@remove_components!](@ref):

```jldoctest; output = false
entity = new_entity!(world, ())

add_components!(world, entity, (Position(0, 0), Velocity(1,1)))
@remove_components!(world, entity, (Velocity,))

# output

```

Note that adding an already existing component of removing a missing one results in an error.

Also note that it is more efficient to add/remove multiple components at once instead of one by one.
To allow for efficient exchange of components (i.e. add some and remove others in the same operation),
[@exchange_components!](@ref) can be used:


```jldoctest; output = false
entity = new_entity!(world, (Position(0, 0), Velocity(1,1)))

@exchange_components!(world, entity, 
    add    = (Health(100),),
    remove = (Position, Velocity),
)

# output

```
