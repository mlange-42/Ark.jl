# Changelog

## [[unpublished]](https://github.com/mlange-42/Ark.jl/compare/v0.1.0...main)

### Breaking changes

- Throws more explicit exception types instead of generic `ErrorException` (#202)

### Features

- Adds an event system with events for structural changes as well as custom events (#155)

### Other

- Improves error messages when passing components types as `(A, B)` instead of the required `Val.((A, B))` (#191)

## [[v0.1.0]](https://github.com/mlange-42/Ark.jl/tree/v0.1.0)

Initial release of Ark.jl.
