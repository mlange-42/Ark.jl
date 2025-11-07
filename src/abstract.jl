
abstract type _AbstractWorld end

"""
    StructArrayStorage

Marks component types for using StructArray-like storage in world constructor.

See also [VectorStorage](@ref).

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
world = World(
    Position => StructArrayStorage,
    Velocity => StructArrayStorage,
)
; # suppress print output

# output

```
"""
abstract type StructArrayStorage end

"""
    VectorStorage

Marks component types for using Vector storage in world constructor.
As this is the default storage mode if the storage type is not specified.

See also [StructArrayStorage](@ref).

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
world = World(
    Position => VectorStorage,
    Velocity => VectorStorage,
)
; # suppress print output

# output

```
"""
abstract type VectorStorage end
