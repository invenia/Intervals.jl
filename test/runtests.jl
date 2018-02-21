using Intervals
using TimeZones
using Base.Test
using Base.Dates

@testset "Intervals" begin
    include("inclusivity.jl")
    include("interval.jl")
    include("anchoredinterval.jl")
end
