
abstract type _AbstractWorld end

"""
    StructArrayStorage

Marks component types for using StructArray-like [storage mode](@ref component-storages) in the world constructor.

In StructArray storages, mutable components are not allowed.

See also [VectorStorage](@ref).

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
world = World(
    Position => StructArrayStorage,
    Velocity => StructArrayStorage,
)

# output

World(entities=0, comp_types=(Position, Velocity))
```
"""
abstract type StructArrayStorage end

"""
    VectorStorage

Marks component types for using Vector [storage mode](@ref component-storages) in the world constructor.
As this is the default storage mode if the storage type is not specified.

See also [StructArrayStorage](@ref).

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
world = World(
    Position => VectorStorage,
    Velocity => VectorStorage,
)

# output

World(entities=0, comp_types=(Position, Velocity))
```
"""
abstract type VectorStorage end
