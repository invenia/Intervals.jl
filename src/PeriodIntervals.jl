__precompile__()

module PeriodIntervals

using Base.Dates
using TimeZones
#using AutoHashEquals

abstract type AbstractInterval end

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
       ..

end
