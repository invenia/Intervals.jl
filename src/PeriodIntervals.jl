__precompile__()

module PeriodIntervals

using Base.Dates
using TimeZones

abstract type AbstractInterval{T} end

include("inclusivity.jl")
include("interval.jl")
include("periodinterval.jl")
include("summary.jl")

export AbstractInterval,
       Interval,
       PeriodInterval,
       PeriodEnding,
       PeriodBeginning,
       HourEnding,
       HourBeginning,
       Inclusivity,
       inclusivity,
       finish,
       span,
       ..

end
