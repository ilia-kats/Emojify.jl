module Emojify
using Random
using CSTParser

export emojify, emojify_string

const emoji = Char.(0x1F400:0x1F6A6)
@enum Status funcdecl funcdef funcname funcargs funcbody ass mod other

function get_status(e::CSTParser.EXPR)
    if CSTParser.headof(e) === :function
        return funcdecl
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

    cst = CSTParser.parse(str, true)
    cu = codeunits(str)

    offset = 1
    stack = Vector{Tuple{CSTParser.EXPR,Status}}()
    replacements = Dict{String,Char}()

    push!(stack, (cst, get_status(cst)))
    while length(stack) > 0
        cst, status = pop!(stack)
        if isnothing(cst.args)
            if CSTParser.isidentifier(cst)
                if status != other
                    cem = emojis[emojiidx]
                    emojiidx += 1
                    replacements[CSTParser.valof(cst)] = cem
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
            if status == funcdecl
                push!(stack, (cst[4], other))
                push!(stack, (cst[3], funcbody))
                push!(stack, (cst[2], funcdef))
                push!(stack, (cst[1], funcdecl))
            elseif status == funcdef
                for i = lastindex(cst):-1:(firstindex(cst)+1)
                    push!(stack, (cst[i], funcargs))
                end
                push!(stack, (cst[1], funcname))
            elseif status == funcargs
                for i = lastindex(cst):-1:(firstindex(cst)+1)
                    push!(stack, (cst[i], other))
                end
                push!(stack, (cst[1], funcargs))
            else
                for i = lastindex(cst):-1:firstindex(cst)
                    ccst = cst[i]
                    cstatus = CSTParser.isidentifier(ccst) ? status : get_status(ccst)
                    push!(stack, (ccst, cstatus))
                end
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
