using Base.Iterators: product
using Dates
using Documenter: doctest
using Infinity: Infinite, InfExtendedReal, InfExtendedTime, InfMinusInfError, ∞
using Intervals
using Intervals: isfinite
using Serialization: deserialize
using Test
using TimeZones

const BOUND_PERMUTATIONS = product((Closed, Open), (Closed, Open))

include("test_utils.jl")

@testset "Intervals" begin
    #include("inclusivity.jl")
    #include("endpoint.jl")
    #include("interval.jl")
    include("anchoredinterval.jl")
    #include("comparisons.jl")
    #include("plotting.jl")

    # Note: The output of the doctests currently requires a newer version of Julia
    # https://github.com/JuliaLang/julia/pull/34387
    # The doctests fail on x86, so only run them on 64-bit hardware
    if v"1.6" <= VERSION < v"1.7" && Sys.WORD_SIZE == 64
        doctest(Intervals)
    else
        @warn "Skipping doctests"
    end
end
