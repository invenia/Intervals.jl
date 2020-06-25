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
    # e.g. `TESTS="interval comparisons"` or `TEST="-plotting"`
    tests = split(get(ENV, "TESTS", ""), r"\s+", keepempty=false)

    isexclude(x) = startswith(x, '-')
    includes = Symbol.(filter(!isexclude, tests))
    excludes = Symbol.(replace.(filter(isexclude, tests), Ref(r"^-" => "")))

    isempty(includes) && (includes = ALL_TESTS)
    setdiff(includes, excludes)
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
