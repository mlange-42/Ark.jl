
module ArkMooncakeInterop

using Ark, Mooncake, Mooncake.Random

Mooncake.tangent_type(::Type{<:Ark._GraphNode}) = Mooncake.NoTangent
Mooncake.tangent_type(::Type{Vector{<:_GraphNode}}) = Mooncake.NoTangent
Mooncake.tangent_type(::Type{<:Ark._VecMap}) = Mooncake.NoTangent
Mooncake.tangent_type(::Type{<:Ark._EventManager}) = Mooncake.NoTangent

Mooncake.@mooncake_overlay Base.sizehint!(A::AbstractVector, n::Integer) = A

end
