using Test
using Random
using Emojify

tmpdir = mktempdir()
@testset "default emoji" begin
    Random.seed!(42)
    emojify(joinpath(@__DIR__, "input", "basetest.jl"), tmpdir)
    for ((refroot, refdirs, reffiles), (testroot, testdirs, testfiles)) in zip(walkdir(joinpath(@__DIR__, "output", "default")), walkdir(tmpdir))
        @test refdirs == testdirs
        @test reffiles == testfiles
        for (reffile, testfile) in zip(reffiles, testfiles)
            @test read(joinpath(refroot, reffile), String) == read(joinpath(testroot, testfile), String)
        end
    end
end

@testset "custom emoji" begin
    emoji = Char.(0x02107:0x0214A)
    Random.seed!(42)
    emojify(joinpath(@__DIR__, "input", "basetest.jl"), tmpdir, emoji)
    for ((refroot, refdirs, reffiles), (testroot, testdirs, testfiles)) in zip(walkdir(joinpath(@__DIR__, "output", "custom")), walkdir(tmpdir))
        @test refdirs == testdirs
        @test reffiles == testfiles
        for (reffile, testfile) in zip(reffiles, testfiles)
            @test read(joinpath(refroot, reffile), String) == read(joinpath(testroot, testfile), String)
        end
    end
end
