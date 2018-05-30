__precompile__()

module Intervals

using Base.Dates
using TimeZones
using Compat: AbstractDateTime

import Base: ⊆, ⊇, ⊈, ⊉, union, union!

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
       union,
       union!,
       less_than_disjoint,
       greater_than_disjoint,
       .., ≪, ≫, ⊆, ⊇, ⊈, ⊉


end
