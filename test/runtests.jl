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

    doctest(Intervals)
end
