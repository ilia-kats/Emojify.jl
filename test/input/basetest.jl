module TestMod
x = 1
testfun() = nothing

include("test.jl")

struct TestStruct
    field1::Int
    field2::Float
end

struct Test2Struct
    field1::TestStruct
    field2::String
end