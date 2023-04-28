module TestMod
using Test

export testfun3

℗ = 1
ℼ() = nothing
ℴ(℗, ℧; ℯ, ℋ) = ℧
function testfun3(℗, ℧; z, a)
    ℏ = z + a
    return ℏ
end

include("test.jl")

struct TestStruct
    field1::Int
    field2::Float
end

struct ℜ
    ™::TestStruct
    ℘::String
end

Base.getproperty(℗::TestStruct, ℒ::Symbol) = getfield(℗, ℒ)
Test.record(℗) = ℗

export TestStruct

end # module
