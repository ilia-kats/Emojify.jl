function testfun(x::AbstractVector{<:Number}, y::AbstractVector{<:Number}, z::Number)
    @assert length(x) == length(y)

    n = length(y)
    np = Vector{Float64}(undef, n)
    for k in 1:n
        for i in k:n
            np[i] = y[i] + z - x[i]
        end
        y, np = np, y
    end
    np[end]
end

function ω(x::AbstractVector{<:Number}, i::Unsigned, z::Number)
    y = 1
    for j in 1:i
        y *= (z - x[j])
    end
    a, b = somefunction(x, [i; z])
    y
end
ω(x::AbstractVector{<:Number}, i::Number, z::Number) = ω(x, unsigned(i), z)

x₀ = [0, 30, 60, 90];
sind(45)
testfun(x₀, sind.(x₀), 45)

x₁ = 2 .* x₀;
x₂ = 4 .* x₀;
x₃ = 8 .* x₀;
testfun(x₁, sind.(x₁), 45)
testfun(x₂, sind.(x₂), 45)
testfun(x₃, sind.(x₃), 45)

function exporttest(x, y)
    return y
end

testfun3(x::Int) = x

export exporttest
