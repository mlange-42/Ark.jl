# API

```@contents
Pages = ["api.md"]
Depth = 2:2
```

## World

The World is...

```@docs
World
is_locked
```

## Map

See also the [Components](@ref Components)-related API.

```@docs
Map
@Map
getindex(::Map, ::Entity)
setindex!(::Map, ::Tuple, ::Entity)
```

## Entities

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

```@docs
Query
@Query
close!(q::Query{W,CS}) where {W<:World,CS<:Tuple}
Entities
```

## Resources

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
