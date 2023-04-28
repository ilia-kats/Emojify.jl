function ℼ(℗::AbstractVector{<:Number}, ℧::AbstractVector{<:Number}, ℯ::Number)
    @assert length(℗) == length(℧)

    ℣ = length(℧)
    ℙ = Vector{Float64}(undef, ℣)
    for ℶ in 1:℣
        for ⅇ in ℶ:℣
            ℙ[ⅇ] = ℧[ⅇ] + ℯ - ℗[ⅇ]
        end
        ℧, ℙ = ℙ, ℧
    end
    ℙ[end]
end

function ℾ(℗::AbstractVector{<:Number}, ⅇ::Unsigned, ℯ::Number)
    ℧ = 1
    for ℭ in 1:ⅇ
        ℧ *= (ℯ - ℗[ℭ])
    end
    ℋ, ℏ = somefunction(℗, [ⅇ; ℯ])
    ℧
end
ℾ(℗::AbstractVector{<:Number}, ⅇ::Number, ℯ::Number) = ℾ(℗, unsigned(ⅇ), ℯ)

ⅈ = [0, 30, 60, 90];
sind(45)
ℼ(ⅈ, sind.(ⅈ), 45)

ℱ = 2 .* ⅈ;
ℐ = 4 .* ⅈ;
ℨ = 8 .* ⅈ;
ℼ(ℱ, sind.(ℱ), 45)
ℼ(ℐ, sind.(ℐ), 45)
ℼ(ℨ, sind.(ℨ), 45)

function exporttest(℗, ℧)
    return ℧
end

testfun3(℗::Int) = ℗

export exporttest
