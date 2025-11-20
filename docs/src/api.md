# API

Ark's public API.

```@contents
Pages = ["api.md"]
Depth = 2:2
```

## [World](@id world-api)

The [World](@ref "The World") is the central data storage for [Entities](@ref entities-api), [Components](@ref components-api)
and [Resources](@ref resources-api).

```@docs
World
World(::Type...; ::Bool)
reset!
is_locked
StructArrayStorage
VectorStorage
```

## [Entities](@id entities-api)

[Entities](@ref) are the "game objects" or "model entities".
An entity if just an ID with a generation, but [Components](@ref components-api)
can be attached to an entity.

```@docs
Entity
zero_entity
new_entity!
new_entities!
remove_entity!
copy_entity!
is_alive
is_zero
```

## [Components](@id components-api)

[Components](@ref) contain the data associated with [Entities](@ref entities-api).

```@docs
get_components
has_components
set_components!
add_components!
remove_components!
exchange_components!
```

## [Queries](@id queries-api)

[Queries](@ref) are used to filter and process [Entities](@ref entities-api) with a
certain set of [Components](@ref components-api).

```@docs
Query
query
close!(::Query)
count_entities(::Query)
length(::Query)
Entities
@unpack
unpack
```

## [Resources](@id resources-api)

[Resources](@ref) are singleton-like data structures that appear only once in a [World](@ref world-api)
and are not associated to an [Entity](@ref entities-api).

```@docs
get_resource
has_resource
add_resource!
set_resource!
remove_resource!
```

## [Batch](@id batch-api)

An iterator over entities that were created or modified using batch operations.
Behaves like a [Query](@ref) and can be used for component initialization.

```@docs
Batch
close!(::Batch)
count_entities(::Batch)
length(::Batch)
```

## [Event system](@id events-api)

The [event system](@ref "Event system") allows user code to react on structural changes
like entity creation and removal and component addition and removal.
Further, custom events can be defined and emitted.

```@docs
EventType
EventRegistry
EventRegistry()
new_event_type!
Observer
observe!
emit_event!
```

## Index

```@index
Pages = ["api.md"]
```
