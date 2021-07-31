module TestMod
using Test

export testfun3

ⅉ = 1
ℭ() = nothing
ℜ(ⅉ, ℳ; ℘, ℮) = ℳ
function testfun3(ⅉ, ℳ; z, a)
    ℴ = z + a
    return ℴ
end

include("test.jl")

struct TestStruct
    field1::Int
    field2::Float
end

struct ℣
    ℔::TestStruct
    ℩::String
end

Base.getproperty(ⅉ::TestStruct, ℐ::Symbol) = getfield(ⅉ, ℐ)
Test.record(ⅉ) = ⅉ

export TestStruct

end # module
