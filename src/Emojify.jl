module Emojify
using Random
using CSTParser

export emojify

const emoji = Char.(0x1F400:0x1F6A6)

mutable struct EmojiEnv
    emojis::Vector{Char}
    emojiidx::Vector{UInt}
    modules::Set{String}
    replacements::Dict{String, String}
    basedir::Union{String, Nothing}
    outdir::Union{String, Nothing}
end
function EmojiEnv(
    emojis::Vector{Char},
    emojiidx::Vector{<:Integer},
    replacements::Dict{String, String},
    basedir::Union{String, Nothing},
    outdir::Union{String, Nothing},
)
    defaultmods = Set(["Base", "Core"])
    EmojiEnv(emojis, emojiidx, defaultmods, replacements, basedir, outdir)
end

function EmojiEnv(basedir::String, outdir::String, emojis::Union{Vector{Char}, Nothing}=emoji)
    if isnothing(emojis)
        emojis=emoji
    end
    EmojiEnv(shuffle(emojis), [1], Dict{String, String}(), abspath(basedir), abspath(outdir))
end
function EmojiEnv(emojis::Union{Vector{Char}, Nothing}=emoji)
    if isnothing(emojis)
        emojis=emoji
    end
    EmojiEnv(shuffle(emojis), [1], Dict{String, String}(), nothing, nothing)
end

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

function _get_string(key::CSTParser.EXPR)
    name = CSTParser.get_name(key)
    if CSTParser.isidentifier(name)
        return CSTParser.valof(name)
    end
    return nothing
end

function _replace(key::CSTParser.EXPR, env::EmojiEnv)
    name = _get_string(key)
    if !isnothing(name)
        _replace(name, env)
    end
end

_isinclude(cst::CSTParser.EXPR) =
    CSTParser.iscall(cst) &&
    CSTParser.valof(CSTParser.get_name(cst)) == "include" &&
    CSTParser.isstringliteral(cst.args[2])

function _get_include(cst::CSTParser.EXPR, include_path::Union{AbstractString, Nothing}=nothing)
    includefile = CSTParser.valof(cst.args[2])
    absp = isabspath(includefile)
    if !absp
        includefile = joinpath(include_path, includefile)
    end
    return includefile, absp
end

function _scan_module_for_exports(
    cst::CSTParser.EXPR,
    include_path::Union{AbstractString, Nothing}=nothing,
)
    exports = Set{String}()
    for p in cst
        if CSTParser.headof(p) === :export
            for exp in p.args
                push!(exports, CSTParser.valof(exp))
            end
        elseif !isnothing(include_path) && _isinclude(p)
            includefile = _get_include(p, include_path)[1]
            union!(
                exports,
                _scan_module_for_exports(
                    CSTParser.parse(read(includefile, String), true),
                    dirname(includefile),
                ),
            )
        end
    end
    return exports
end

function _emojify_string(
    str::AbstractString,
    out::IO,
    env::EmojiEnv,
    include_path::Union{AbstractString, Nothing}=nothing,
    errorstring="input",
    exports::Set{String}=Set{String}(),
)
    cst = CSTParser.parse(str, true)
    cu = codeunits(str)

    offset = 1
    stack = Vector{Tuple{CSTParser.EXPR, Set{String}, Set{String}}}()
    push!(stack, (cst, Set{String}(), exports))

    while length(stack) > 0
        cst, replacemask, exports = pop!(stack)
        if isnothing(cst.args)
            if CSTParser.isidentifier(cst) &&
               haskey(env.replacements, CSTParser.valof(cst)) &&
               !(CSTParser.valof(cst) in replacemask)
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
                exported = CSTParser.valof(CSTParser.get_name(cst)) in exports
                for (i, sigpart) in enumerate(CSTParser.get_sig(cst))
                    if exported && i == 1
                        continue
                    end
                    if CSTParser.isparameters(sigpart)
                        if exported
                            replacemask = copy(replacemask)
                            for param in sigpart
                                name = _get_string(CSTParser.get_arg_name(param))
                                !isnothing(name) && push!(replacemask, name)
                            end
                        else
                            for param in sigpart
                                _replace(CSTParser.get_arg_name(param), env)
                            end
                        end
                    else
                        _replace(CSTParser.get_arg_name(sigpart), env)
                    end
                end
            elseif CSTParser.is_getfield(cst) &&
                   CSTParser.valof(CSTParser.unquotenode(cst)) in env.modules
                replacemask = copy(replacemask)
                push!(replacemask, _get_string(CSTParser.get_name(cst)))
                push!(replacemask, _get_string(CSTParser.get_sig(cst)))
            elseif CSTParser.isassignment(cst)
                _replace(cst[1], env)
            elseif CSTParser.defines_datatype(cst) &&
                   !(CSTParser.valof(CSTParser.get_name(cst)) in exports)
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
                includefile, absp = _get_include(cst, include_path)
                newpath = _emojify_file(includefile, env, exports)
                if absp
                    cst.args[2].val = "\"$newpath\""
                    cst.args[2].span = -1
                end
            elseif CSTParser.headof(cst) === :using || CSTParser.headof(cst) === :import
                for arg in cst.args
                    for carg in arg.args
                        if CSTParser.isidentifier(carg)
                            push!(env.modules, CSTParser.valof(carg))
                        end
                    end
                end
            elseif CSTParser.defines_module(cst)
                for c in cst
                    if CSTParser.headof(c) === :block # body of module
                        exports = _scan_module_for_exports(c, include_path)
                        break
                    end
                end
            end

            for i in length(cst):-1:1
                push!(stack, (cst[i], replacemask, exports))
            end
        end
    end
end

function _emojify_file(file::AbstractString, env::EmojiEnv, exports::Set{String}=Set{String}())
    origin = read(file, String)

    outdir = env.outdir
    include_path, filename = splitdir(file)
    subdir = include_path[(length(env.basedir) + 1):end]
    env.outdir = mkpath(joinpath(outdir, subdir))
    outfile = joinpath(env.outdir, filename)
    open(outfile, "w") do out
        _emojify_string(origin, out, env, include_path, file, exports)
    end
    env.outdir = outdir
    return outfile
end

function emojify(str::AbstractString, emojis::Union{Vector{Char}, Nothing}=nothing)
    out = IOBuffer(sizehint=sizeof(str))
    _emojify_string(str, out, EmojiEnv(emojs))
    return String(take!(out))
end

function emojify(infile::AbstractString, outdir::AbstractString, emojis::Union{Vector{Char}, Nothing}=nothing)
    _emojify_file(abspath(infile), EmojiEnv(dirname(infile), outdir, emojis))
    nothing
end

end # module
