module TestMod
using Test

export testfun3

🕼 = 1
👴() = nothing
🗍(🕼, 🖅; 📄, 🗫) = 🖅
function testfun3(🕼, 🖅; z, a)
    🐺 = z + a
    return 🐺
end

include("test.jl")

struct TestStruct
    field1::Int
    field2::Float
end

struct 💊
    🔷::TestStruct
    🙂::String
end

Base.getproperty(🕼::TestStruct, 🔆::Symbol) = getfield(🕼, 🔆)
Test.record(🕼) = 🕼

export TestStruct

end # module
