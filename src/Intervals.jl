__precompile__()

module Intervals

using Base.Dates
using TimeZones
using Compat: AbstractDateTime

import Base: ⊆, ⊇, ⊈, ⊉

abstract type AbstractInterval{T} end

include("inclusivity.jl")
include("endpoint.jl")
include("interval.jl")
include("anchoredinterval.jl")
include("description.jl")

export AbstractInterval,
       Interval,
       AnchoredInterval,
       IntervalEnding,
       IntervalBeginning,
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
       less_than_disjoint,
       greater_than_disjoint,
       .., ≪, ≫, ⊆, ⊇, ⊈, ⊉


end
