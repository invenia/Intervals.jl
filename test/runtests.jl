using Dates
using Plots
using Intervals
using Intervals: isunbounded
using TimeZones
using Test
using VisualRegressionTests

@testset "Intervals" begin
    #include("inclusivity.jl")
    #include("endpoint.jl")
    include("interval.jl")
    #include("anchoredinterval.jl")
    #include("comparisons.jl")
    #include("plotting.jl")
end
