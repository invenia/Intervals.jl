using Intervals
using TimeZones
using Test
using Dates


mod_prefix = tz_prefix = ""

@testset "Intervals" begin
    include("inclusivity.jl")
    include("endpoint.jl")
    include("interval.jl")
    include("anchoredinterval.jl")
    include("comparisons.jl")
end
