using PeriodIntervals
using TimeZones
using Base.Test
using Base.Dates

@testset "PeriodIntervals" begin
    include("inclusivity.jl")
    include("interval.jl")
    include("periodinterval.jl")
end
