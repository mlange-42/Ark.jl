# Systems

Ark provides **no systems** as they are widely known in ECS implementations.
This is a deliberate decision, based on these reasons:

- Systems can be hard to integrate into frameworks, like a game engine's update loop.  
  Ark wants to stay flexible and is completely engine-agnostic.
- Systems are usually tied to queries in a 1:1 relation, while it is easily possible to combine multiple queries.
- Systems and a scheduler are easy to implement, so this is left to the user.

Below, we provide an example for how to implement systems and a scheduler.

## Systems example

### [Components](@id sys-components)

We start by defining our component types:

```jldoctest systems; output = false
using Ark

struct Position
    x::Float64
    y::Float64
end
struct Velocity
    dx::Float64
    dy::Float64
end

# output

```

### Abstract system type

We write an abstract system type.
This is optional, but useful for clarity and to avoid boilerplate.

```jldoctest systems; output = false
abstract type System end

function initialize!(::System, ::World) end
function update!(::System, ::World) end
function finalize!(::System, ::World) end

# output

finalize! (generic function with 1 method)
```

### Scheduler

Next, we build a (type-stable) scheduler:

```jldoctest systems; output = false
struct Scheduler{ST<:Tuple}
    world::World
    systems::ST
end

function run!(s::Scheduler, steps::Int)
    # initialize all systems
    for sys in s.systems
        initialize!(sys, s.world)
    end

    # update loop
    for _ in 1:steps
        # update all systems
        for sys in s.systems
            update!(sys, s.world)
        end
    end
    
    # finalize all systems
    for sys in s.systems
        finalize!(sys, s.world)
    end
end

# output

run! (generic function with 1 method)
```

### Initializer system

Now we can write some systems. First one that creates some entities.

```jldoctest systems; output = false
struct InitializerSystem <: System
    count::Int
end

function initialize!(s::InitializerSystem, w::World)
    for (entities, positions, velocities) in new_entities!(w, s.count, (Position, Velocity))
        @inbounds for i in eachindex(entities)
            positions[i] = Position(rand() * 100, rand() * 100)
            velocities[i] = Velocity(randn(), randn())
        end
    end
end

# output

initialize! (generic function with 2 methods)
```

As we have the abstract type, we only need to implement the functions that are required for the system.

### Movement system

And here the classical movement system:

```jldoctest systems; output = false
struct MovementSystem <: System end

function update!(s::InitializerSystem, w::World)
    for (entities, positions, velocities) in Query(world, (Position, Velocity))
        @inbounds for i in eachindex(entities)
            pos = positions[i]
            vel = velocities[i]
            positions[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
        end
    end
end

# output

update! (generic function with 2 methods)
```

### Putting it together

Finally, we can plug everything together:

```jldoctest systems; output = false
world = World(Position, Velocity)

scheduler = Scheduler(
    world,
    (
        InitializerSystem(100),
        MovementSystem(),
    ),
)

run!(scheduler, 1000)

# output

```
