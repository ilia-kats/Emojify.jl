using Test
using Random
using Emojify

tmpdir = mktempdir()
Random.seed!(42)
@testset begin
    emojify(joinpath(@__DIR__, "input", "basetest.jl"), tmpdir)
    for ((refroot, refdirs, reffiles), (testroot, testdirs, testfiles)) in zip(walkdir(joinpath(@__DIR__, "output")), walkdir(tmpdir))
        @test refdirs == testdirs
        @test reffiles == testfiles
        for (reffile, testfile) in zip(reffiles, testfiles)
            @test read(joinpath(refroot, reffile), String) == read(joinpath(testroot, testfile), String)
        end
    end
end
