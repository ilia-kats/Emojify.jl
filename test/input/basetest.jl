module TestMod
using Test

export testfun3

x = 1
testfun() = nothing
testfun2(x, y; z, a) = y
function testfun3(x, y; z, a)
    b = z + a
    return b
end

include("test.jl")

struct TestStruct
    field1::Int
    field2::Float
end

struct Test2Struct
    field1::TestStruct
    field2::String
end

Base.getproperty(x::TestStruct, name::Symbol) = getfield(x, name)
Test.record(x) = x

export TestStruct

end # module
