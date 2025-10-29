# API

Ark's public API.

```@contents
Pages = ["api.md"]
Depth = 2:2
```

## [World](@id world-api)

The World is the central data storage for [Entities](@ref entities-api), [Components](@ref components-api)
and [Resources](@ref resources-api).

```@docs
World
is_locked
```

## [Entities](@id entities-api)

Entities are the "game objects" or "model entities".
An entity if just an ID with a generation, but [Components](@ref components-api)
can be attached to an entity.

```@docs
Entity
zero_entity
new_entity!
new_entities!
@new_entities!
remove_entity!
is_alive
is_zero
```

## [Components](@id components-api)

Components contain the data associated with [Entities](@ref entities-api)

```@docs
get_components
@get_components
has_components
@has_components
set_components!
add_components!
remove_components!
@remove_components!
exchange_components!
@exchange_components!
```

## [Queries](@id queries-api)

Queries are used to filter and process [Entities](@ref entities-api) with a
certain set of [Components](@ref components-api).

```@docs
Query
@Query
close!(q::Query{W,CS}) where {W<:World,CS<:Tuple}
Entities
```

## [Resources](@id resources-api)

Resources are singleton-like data structures that appear only once in a [World](@ref world-api)
and are not associated to an [Entity](@ref entities-api).

```@docs
get_resource
has_resource
add_resource!
remove_resource!
```

## [Batch](@id batch-api)

An iterator over entities that were created or modified using batch operations.
Behaves like a [Query](@ref) and can be used for component initialization.

```@docs
Batch
close!(b::Batch{W,CS}) where {W<:World,CS<:Tuple}
```

## Index

```@index
Pages = ["api.md"]
```
