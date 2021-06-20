module TestMod
using Test

🕼 = 1
👴() = nothing

include("test.jl")

struct 🗵
    📹::Int
    🗜::Float
end

struct 💊
    📹::🗵
    🗜::String
end

Base.getproperty(🕼::🗵, 🙂::Symbol) = getfield(🕼, 🙂)
Test.record(🕼) = 🕼
