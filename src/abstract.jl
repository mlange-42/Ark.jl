abstract type _AbstractWorld end

"""
    StructArrayComponent

Marker trait for component types that use a StructArray-like storage.

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
