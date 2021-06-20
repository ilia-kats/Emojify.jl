module Emojify
using Random
using CSTParser

export emojify

const emoji = Char.(0x1F400:0x1F6A6)

mutable struct EmojiEnv
    emojis::Vector{Char}
    emojiidx::Vector{UInt}
    replacements::Dict{String, String}
    basedir::Union{String, Nothing}
    outdir::Union{String, Nothing}
end

EmojiEnv(basedir::String, outdir::String, emojis::Vector{Char}=emoji) = EmojiEnv(shuffle(emojis), [1], Dict{String, String}(), abspath(basedir), abspath(outdir))
EmojiEnv(emojis::Vector{Char}=emoji) = EmojiEnv(shuffle(emojis), [1], Dict{String, String}(), nothing, nothing)

function _replace(key::AbstractString, env::EmojiEnv)
    if !haskey(env.replacements, key)
        env.replacements[key] = String([env.emojis[i] for i in env.emojiidx])
        cidx = length(env.emojiidx)
        while cidx > 0
            env.emojiidx[cidx] += 1
            if env.emojiidx[cidx] > length(env.emojis)
                env.emojiidx[cidx] = 1
                cidx -= 1
            else
                break
            end
        end
        if cidx == 0
            push!(env.emojiidx, 1)
        end
    end
end

function _replace(key::CSTParser.EXPR, env::EmojiEnv)
    name = CSTParser.valof(CSTParser.get_name(key))
    if !isnothing(name)
        _replace(name, env)
    end
end

_isinclude(cst::CSTParser.EXPR) = CSTParser.iscall(cst) && CSTParser.valof(CSTParser.get_name(cst)) == "include" && CSTParser.isstringliteral(cst.args[2])

function _emojify_string(str::AbstractString, out::IO, env::EmojiEnv, include_path::Union{AbstractString, Nothing}=nothing, errorstring="input")
    cst = CSTParser.parse(str, true)
    cu = codeunits(str)

    offset = 1
    stack = Vector{CSTParser.EXPR}()
    push!(stack, cst)

    while length(stack) > 0
        cst = pop!(stack)
        if isnothing(cst.args)
            if CSTParser.isidentifier(cst) && haskey(env.replacements, CSTParser.valof(cst))
                cem = env.replacements[CSTParser.valof(cst)]
                write(out, cem)
                if cst.fullspan > cst.span
                    write(out, cu[(offset + cst.span):(offset + cst.fullspan - 1)])
                end
            elseif cst.span >= 0
                write(out, cu[offset:(offset + cst.fullspan - 1)])
            elseif !isnothing(CSTParser.valof(cst))
                write(out, CSTParser.valof(cst))
            elseif CSTParser.headof(cst) === :errortoken
                error("Syntax error in $errorstring")
            end
            offset += cst.fullspan
        else
            if CSTParser.defines_function(cst)
                for sigpart in CSTParser.get_sig(cst)
                    _replace(CSTParser.get_arg_name(sigpart), env)
                end
            elseif CSTParser.isparameters(cst)
                for param in cst
                    _replace(CSTParser.get_arg_name(param), env)
                end
            elseif CSTParser.isassignment(cst)
                _replace(cst[1], env)
            elseif CSTParser.defines_datatype(cst)
                _replace(cst, env)
                for c in cst
                    if CSTParser.headof(c) === :block # body of type definition
                        for cb in c
                            _replace(cb, env)
                        end
                        break
                    end
                end
            elseif !isnothing(include_path) && _isinclude(cst)
                includefile = CSTParser.valof(cst.args[2])
                absp = isabspath(includefile)
                if !absp
                    includefile = joinpath(include_path, includefile)
                end
                newpath = _emojify_file(includefile, env)
                if absp
                    cst.args[2].val = "\"$newpath\""
                    cst.args[2].span = -1
                end
            end

            for i in lastindex(cst):-1:(firstindex(cst))
                push!(stack, cst[i])
            end
        end
    end
end

function _emojify_file(file::AbstractString, env::EmojiEnv)
    origin = read(file, String)

    outdir = env.outdir
    include_path, filename = splitdir(file)
    subdir = include_path[length(env.basedir) + 1:end]
    env.outdir = mkpath(joinpath(outdir, subdir))
    outfile = joinpath(env.outdir, filename)
    open(outfile, "w") do out
        _emojify_string(origin, out, env, include_path, file)
    end
    env.outdir = outdir
    return outfile
end

function emojify(str::AbstractString)
    out = IOBuffer(sizehint=sizeof(str))
    _emojify_string(str, out, EmojiEnv())
    return String(take!(out))
end

function emojify(infile::AbstractString, outdir::AbstractString)
    _emojify_file(abspath(infile), EmojiEnv(dirname(infile), outdir))
    nothing
end

end # module
