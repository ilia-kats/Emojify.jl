module Emojify
using Random
using CSTParser

export emojify, emojify_string

const emoji = Char.(0x1F400:0x1F6A6)

function _emojify_string(str::AbstractString, out::IO)
    emojis = shuffle(emoji)
    emojiidx = [1]

    cst = CSTParser.parse(str, true)
    cu = codeunits(str)

    offset = 1
    stack = Vector{CSTParser.EXPR}()
    replacements = Dict{String, String}()

    function replace(key::AbstractString)
        if !haskey(replacements, key)
            replacements[key] = String([emojis[i] for i in emojiidx])
            cidx = length(emojiidx)
            while cidx > 0
                emojiidx[cidx] += 1
                if emojiidx[cidx] > length(emojis)
                    emojiidx[cidx] = 1
                    cidx -= 1
                else
                    break
                end
            end
            if cidx == 0
                push!(emojiidx, 1)
            end
        end
    end

    function replace(key::CSTParser.EXPR)
        name = CSTParser.valof(CSTParser.get_name(key))
        if !isnothing(name)
            replace(name)
        end
    end

    push!(stack, cst)
    while length(stack) > 0
        cst = pop!(stack)
        if isnothing(cst.args)
            if CSTParser.isidentifier(cst) && haskey(replacements, CSTParser.valof(cst))
                cem = replacements[CSTParser.valof(cst)]
                write(out, cem)
                if cst.fullspan > cst.span
                    write(out, cu[(offset + cst.span):(offset + cst.fullspan - 1)])
                end
            else
                write(out, cu[offset:(offset + cst.fullspan - 1)])
            end
            offset += cst.fullspan
        else
            if CSTParser.defines_function(cst)
                for sigpart in CSTParser.get_sig(cst)
                    replace(CSTParser.get_arg_name(sigpart))
                end
            elseif CSTParser.isparameters(cst)
                for param in cst
                    replace(CSTParser.get_arg_name(param))
                end
            elseif CSTParser.isassignment(cst)
                replace(cst[1])
            elseif CSTParser.defines_datatype(cst)
                replace(cst)
                for c in cst
                    if CSTParser.headof(c) === :block # body of type definition
                        for cb in c
                            replace(cb)
                        end
                        break
                    end
                end
            end

            for i in lastindex(cst):-1:(firstindex(cst))
                push!(stack, cst[i])
            end
        end
    end
end

function emojify_string(str::AbstractString)
    out = IOBuffer(sizehint=sizeof(str))
    _emojify_string(str, out)
    return String(take!(out))
end

function emojify(infile::AbstractString)
    return emojify_string(read(infile, String))
end

function emojify(infile::AbstractString, outfile::AbstractString)
    open(outfile, "w") do out
        _emojify_string(read(infile, String), out)
    end
end

end # module
