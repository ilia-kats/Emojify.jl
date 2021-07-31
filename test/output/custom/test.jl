function ℭ(ⅉ::AbstractVector{<:Number}, ℳ::AbstractVector{<:Number}, ℘::Number)
    @assert length(ⅉ) == length(ℳ)

    ℬ = length(ℳ)
    ⅆ = Vector{Float64}(undef, ℬ)
    for ℿ in 1:ℬ
        for K in ℿ:ℬ
            ⅆ[K] = ℳ[K] + ℘ - ⅉ[K]
        end
        ℳ, ⅆ = ⅆ, ℳ
    end
    ⅆ[end]
end

function ℯ(ⅉ::AbstractVector{<:Number}, K::Unsigned, ℘::Number)
    ℳ = 1
    for ℍ in 1:K
        ℳ *= (℘ - ⅉ[ℍ])
    end
    ℳ
end
ℯ(ⅉ::AbstractVector{<:Number}, K::Number, ℘::Number) = ℯ(ⅉ, unsigned(K), ℘)

ℚ = [0, 30, 60, 90];
sind(45)
ℭ(ℚ, sind.(ℚ), 45)

ℹ = 2 .* ℚ;
⅁ = 4 .* ℚ;
ℶ = 8 .* ℚ;
ℭ(ℹ, sind.(ℹ), 45)
ℭ(⅁, sind.(⅁), 45)
ℭ(ℶ, sind.(ℶ), 45)

function exporttest(ⅉ, ℳ)
    return ℳ
end

testfun3(ⅉ::Int) = ⅉ

export exporttest
