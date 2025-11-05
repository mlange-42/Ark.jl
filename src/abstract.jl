
"""
Component storage mode for world construction.

  - `VectorStorage`: Component stored as AoS.
  - `StructArrayStorage`: Component stored as SoA.
  - `InferredStorage`: Storage type inferred from presence of [StructArrayComponent](@ref).
"""
@enum StorageMode VectorStorage StructArrayStorage InferredStorage

abstract type _AbstractWorld end

"""
    StructArrayComponent

Marker trait for component types that use a StructArray-like storage.

Can be overwritten by using [StorageMode](@ref) during world construction.

# Example

```jldoctest; setup = :(using Ark), output = false
struct Position <: StructArrayComponent
    x::Float64
    y::Float64
end

# output

```
"""
abstract type StructArrayComponent end
