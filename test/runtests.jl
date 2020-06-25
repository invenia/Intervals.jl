using Base.Iterators: product
using Dates
using Documenter: doctest
using Intervals
using Test
using TimeZones

const BOUND_PERMUTATIONS = product((Closed, Open), (Closed, Open))

const ALL_TESTS = (
    :inclusivity,
    :endpoint,
    :interval,
    :anchoredinterval,
    :comparisons,
    :plotting,
    :doctest,
)

const TESTS = let
    tests = Symbol.(split(get(ENV, "TESTS", ""), r"\s+", keepempty=false))
    if isempty(tests)
        ALL_TESTS
    else
        tests
    end
end

@testset "Intervals" begin
    :inclusivity in TESTS && include("inclusivity.jl")
    :endpoint in TESTS && include("endpoint.jl")
    :interval in TESTS && include("interval.jl")
    :anchoredinterval in TESTS && include("anchoredinterval.jl")
    :comparisons in TESTS && include("comparisons.jl")
    :plotting in TESTS && include("plotting.jl")
    :doctest in TESTS && doctest(Intervals)
end
