
module ArkMooncakeInterop

using Ark, Mooncake

Mooncake.tangent_type(::Type{<:Ark._GraphNode}) = Mooncake.NoTangent
Mooncake.tangent_type(::Type{<:Ark._VecMap}) = Mooncake.NoTangent
Mooncake.tangent_type(::Type{<:Ark._EventManager}) = Mooncake.NoTangent

Mooncake.@mooncake_overlay function Base.sizehint!(A::AbstractVector, n::Integer)
    return A
end

end