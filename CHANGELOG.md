# Changelog

## [[unpublished]](https://github.com/mlange-42/Ark.jl/compare/v0.1.0...main)

### Breaking changes

- Macros use semicolon instead of comma before kwargs, just like function (#193)
- Throws more explicit exception types instead of generic `ErrorException` (#202)
- Query argument `optional` adds further components instead of making existing ones optional (#253)

### Features

- Adds an event system with events for structural changes as well as custom events (#155)
- Adds storage modes Vector and StructArray, which can be selected per component type (#207, #225)
- Adds field view, so field access for query columns works equally for Vector and StructArray storages (#213)

### Performance

- Adaptive bit-mask size, depending on the number of components in the world (#237, #250)
- Avoids unions in queries without optional components, speeding up query iteration (#246)

### Other

- Improves error messages when passing components types as `(A, B)` instead of the required `Val.((A, B))` (#191)
- Checks for duplicate components on query construction (#255)

## [[v0.1.0]](https://github.com/mlange-42/Ark.jl/tree/v0.1.0)

Initial release of Ark.jl.
