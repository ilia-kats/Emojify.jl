# Emojify.jl

Emojify helps you spread chaos by replacing function and variable names in your code with random emoji.
The output is still valid Julia code.

## Emojify your code
You can use either a string with Julia code as input, or a file path.
If a file path is given, all files referenced with `include()` will also be emojified.

For example,
```julia
using Emojify
emojify("
function ω(x::AbstractVector{<:Number}, i::Unsigned, z::Number)
    y = 1
    for j in 1:i
        y *= (z - x[j])
    end
    y
end
ω(x::AbstractVector{<:Number}, i::Number, z::Number) = ω(x, unsigned(i), z)
")
```
will return
```julia
function 🖴(🕼::AbstractVector{<:Number}, 👖::Unsigned, 📄::Number)
    🖅 = 1
    for 🖥 in 1:👖
        🖅 *= (📄 - 🕼[🖥])
    end
    🖅
end
🖴(🕼::AbstractVector{<:Number}, 👖::Number, 📄::Number) = 🖴(🕼, unsigned(👖), 📄)
```

To emojify a file, use
```julia
using Emojify
emojify("path_to_input_file.jl", "path_to_output_directory")
```

## Emojifying base Julia functions
To achieve absolute chaos, I recommend using this package together with [WatchJuliaBurn.jl](https://github.com/theogf/WatchJuliaBurn.jl).
