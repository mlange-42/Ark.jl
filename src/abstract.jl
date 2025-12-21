
abstract type _AbstractWorld end

"""
    Relationship

Abstract marker type for relationship components.

# Example

```jldoctest; setup = :(using Ark), output = false
struct ChildOf <: Relationship end

# output

```
"""
abstract type Relationship end

"""
    AbstractStorage

Abstract Type all storage modes must be subtype of.
"""
abstract type AbstractStorage end

"""
    StructArrayStorage <: AbstractStorage

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
struct StructArrayStorage <: AbstractStorage end

"""
    VectorStorage <: AbstractStorage

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
struct VectorStorage <: AbstractStorage end
