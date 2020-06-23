using Base.Iterators: product
using Dates
using Documenter: doctest
using Intervals
using Test
using TimeZones

const BOUND_PERMUTATIONS = product((Closed, Open), (Closed, Open))

@testset "Intervals" begin
    include("inclusivity.jl")
    include("endpoint.jl")
    include("interval.jl")
    include("anchoredinterval.jl")
    include("comparisons.jl")
    include("plotting.jl")

    doctest(Intervals)
end
