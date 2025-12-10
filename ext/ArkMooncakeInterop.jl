
module ArkMooncakeInterop

using Ark, Mooncake, Mooncake.Random

Mooncake.tangent_type(::Type{<:Ark._GraphNode}) = Mooncake.NoTangent
Mooncake.tangent_type(::Type{<:Ark._VecMap}) = Mooncake.NoTangent
Mooncake.tangent_type(::Type{<:Ark._EventManager}) = Mooncake.NoTangent

Mooncake.@mooncake_overlay Base.sizehint!(A::AbstractVector, n::Integer) = A
Mooncake.@mooncake_overlay Random.rand!(A::AbstractArray) = rand!(Random.default_rng(), A)
Mooncake.@mooncake_overlay function Random.rand!(rng::Random.AbstractRNG, A::AbstractArray)
    for i in eachindex(A)
        A[i] = rand(rng)
    end
    return A
end

end
