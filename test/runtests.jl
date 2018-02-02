using PeriodIntervals
using Base.Test

@testset "PeriodIntervals" begin
    include("inclusivity.jl")
    include("interval.jl")
    @test 1 == 2
end
