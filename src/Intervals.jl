__precompile__()

module Intervals

using Base.Dates
using TimeZones
using Compat: AbstractDateTime

abstract type AbstractInterval{T} end

include("inclusivity.jl")
include("endpoint.jl")
include("interval.jl")
include("anchoredinterval.jl")
include("description.jl")

export AbstractInterval,
       Interval,
       AnchoredInterval,
       HourEnding,
       HourBeginning,
       HE,
       HB,
       Inclusivity,
       inclusivity,
       first,
       last,
       isclosed,
       anchor,
       span,
       disjoint_less_than,
       disjoint_greater_than,
       ..,
       ≪,
       ≫

end
