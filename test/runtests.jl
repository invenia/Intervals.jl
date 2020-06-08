using Dates
using Intervals
using Intervals: isclosed, isopen
using Test
using TimeZones

@testset "Intervals" begin
    include("inclusivity.jl")
    include("endpoint.jl")
    include("interval.jl")
    include("anchoredinterval.jl")
    include("comparisons.jl")
    include("plotting.jl")
end
