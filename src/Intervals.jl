__precompile__()

module Intervals

using Base.Dates
using TimeZones

abstract type AbstractInterval{T} end

include("inclusivity.jl")
include("interval.jl")
include("anchoredinterval.jl")
include("summary.jl")

export AbstractInterval,
       Interval,
       AnchoredInterval,
       HourEnding,
       HourBeginning,
       Inclusivity,
       inclusivity,
       first,
       last,
       isclosed,
       anchor,
       span,
       ..

end
