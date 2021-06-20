function 👴(🕼::AbstractVector{<:Number}, 🗫::AbstractVector{<:Number}, 🐺::Number)
    @assert length(🕼) == length(🗫)

    🙹 = length(🗫)
    🕌 = Vector{Float64}(undef, 🙹)
    for 🗯 in 1:🙹
        for 👖 in 🗯:🙹
            🕌[👖] = 🗫[👖] + 🐺 - 🕼[👖]
        end
        🗫, 🕌 = 🕌, 🗫
    end
    🕌[end]
end

function 🖴(🕼::AbstractVector{<:Number}, 👖::Unsigned, 🐺::Number)
    🗫 = 1
    for 🖥 in 1:👖
        🗫 *= (🐺 - 🕼[🖥])
    end
    🗫
end
🖴(🕼::AbstractVector{<:Number}, 👖::Number, 🐺::Number) = 🖴(🕼, unsigned(👖), 🐺)

🚘 = [0, 30, 60, 90];
sind(45)
👴(🚘, sind.(🚘), 45)

🗵 = 2 .* 🚘;
📹 = 4 .* 🚘;
🗜 = 8 .* 🚘;
👴(🗵, sind.(🗵), 45)
👴(📹, sind.(📹), 45)
👴(🗜, sind.(🗜), 45)
