
abstract type _AbstractWorld end

"""
    StructArrayComponent

Marks component types for using StructArray-like storage in world constructor.

See also [VectorComponent](@ref).

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
world = World(
    Position => StructArrayComponent,
    Velocity => StructArrayComponent,
)
; # suppress print output

# output

```
"""
abstract type StructArrayComponent end

"""
    VectorComponent

Marks component types for using Vector storage in world constructor.
As this is the default storage mode if the storage type is not specified.

See also [StructArrayComponent](@ref).

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
world = World(
    Position => VectorComponent,
    Velocity => VectorComponent,
)
; # suppress print output

# output

```
"""
abstract type VectorComponent end
