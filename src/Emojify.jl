module Emojify
using Random
using CSTParser

export emojify, emojify_string

const emoji = Char.(0x1F400:0x1F6A6)
@enum Status funcdef funcargs ass mod other

function get_status(e::CSTParser.EXPR)
    if CSTParser.defines_function(e)
        return funcdef
    elseif CSTParser.isassignment(e)
        return ass
    elseif CSTParser.defines_module(e)
        return mod
    else
        return other
    end
end

function _emojify_string(str::AbstractString, out::IO)
    emojis = shuffle(emoji)
    emojiidx = 1

    cst = CSTParser.parse(str)
    cu = codeunits(str)

    offset = 1
    stack = Vector{CSTParser.EXPR}()
    replacements = Dict{String,Char}()

    status = get_status(cst)
    push!(stack, cst)
    while length(stack) > 0
        cst = pop!(stack)
        if isnothing(cst.args)
            if CSTParser.isidentifier(cst)
                if status != other
                    cem = emojis[emojiidx]
                    emojiidx += 1
                    replacements[CSTParser.valof(cst)] = cem

                    if status == funcdef
                        status = funcargs
                    elseif status != funcargs
                        status = other
                    end
                elseif haskey(replacements, CSTParser.valof(cst))
                    cem = replacements[CSTParser.valof(cst)]
                else
                    cem = CSTParser.valof(cst)
                    #@warn "no replacement for identifier $cem at offset $offset"
                end
                write(out, cem)
                if cst.fullspan > cst.span
                    write(out, cu[(offset+cst.span):(offset+cst.fullspan-1)])
                end
            else
                write(out, cu[offset:(offset+cst.fullspan-1)])
            end
            offset += cst.fullspan
        else
            if status == other || status == funcargs
                status = get_status(cst)
            end
            for i = lastindex(cst):-1:firstindex(cst)
                push!(stack, cst[i])
            end
        end
    end
end

function emojify_string(str::AbstractString)
    out = IOBuffer(sizehint = sizeof(str))
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
