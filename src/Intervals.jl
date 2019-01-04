__precompile__()

module Intervals

using Compat
using Compat.Dates
using Compat.Printf
using TimeZones

using Compat.Dates: value, coarserperiod
using Compat: AbstractDateTime

import Base: ⊆, ⊇, ⊈, ⊉, union, union!, merge

abstract type AbstractInterval{T} end

Base.eltype(::AbstractInterval{T}) where {T} = T

if VERSION >= v"0.7"
    Base.broadcastable(x::AbstractInterval) = Ref(x)
end

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
       merge,
       union,
       union!,
       less_than_disjoint,
       greater_than_disjoint,
       superset,
       .., ≪, ≫, ⊆, ⊇, ⊈, ⊉
end
