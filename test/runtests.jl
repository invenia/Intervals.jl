using Arrow
using Base.Iterators: product
using Dates
using Documenter: doctest
using Infinity: Infinite, InfExtendedReal, InfExtendedTime, InfMinusInfError, ∞
using Intervals
using Intervals: isfinite
using Serialization: deserialize
using Test
using TimeZones
using UTCDateTimes

const BOUND_PERMUTATIONS = product((Closed, Open), (Closed, Open))

include("test_utils.jl")

@testset "Intervals" begin
    include("inclusivity.jl")
    include("endpoint.jl")
    include("interval.jl")
    include("anchoredinterval.jl")
    include("comparisons.jl")
    include("sets.jl")
    include("arrow.jl")
    include("plotting.jl")

    # only run doctests on one version (LTS)
    if v"1.10" <= VERSION < v"1.11"
        doctest(Intervals)
    else
        @warn "Skipping doctests"
    end
end
