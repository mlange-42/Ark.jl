# API

Ark's public API.

```@contents
Pages = ["api.md"]
Depth = 2:2
```

## World

The World is the central data storage for [Entities](@ref Entities), [Components](@ref Components)
and [Resources](@ref Resources).

```@docs
World
is_locked
```

## Entities

Entities are the "game objects" or "model entities".
An entity if just an ID with a generation, but [Components](@ref Components)
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

## Components

Components contain the data associated with [Entities](@ref Entities)

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

## Queries

Queries are used to filter and process [Entities](@ref Entities) with a
certain set of [Components](@ref Components).

```@docs
Query
@Query
close!(q::Query{W,CS}) where {W<:World,CS<:Tuple}
Entities
```

## Resources

Resources are singleton-like data structures that appear only once in a [World](@ref World)
and are not associated to an [Entities](@ref Entity).

```@docs
get_resource
has_resource
add_resource!
remove_resource!
```

## Batch

```@docs
Batch
close!(b::Batch{W,CS}) where {W<:World,CS<:Tuple}
```

## Index

```@index
Pages = ["api.md"]
```
