
abstract type _AbstractWorld end

"""
    StructArrayComponent

Marker trait for component types that use a StructArray-like storage.

Can be overwritten by using it during world construction.
See also [VectorComponent](@ref).

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

"""
    StructArrayComponent

Marker trait for component types that use a Vector storage.
As this is the default storage mode, components don't need to be a sub-type of this.

However, it can be used during world construction to overwrite the storage mode.
See also [StructArrayComponent](@ref).
"""
abstract type VectorComponent end

abstract type _InferredComponent end
