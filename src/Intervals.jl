module Intervals

using Dates
using Printf
using RecipesBase
using TimeZones

using Dates: AbstractDateTime, value, coarserperiod

import Base: ⊆, ⊇, ⊈, ⊉, union, union!, merge

abstract type AbstractInterval{T,L,R} end

Base.eltype(::AbstractInterval{T}) where {T} = T
Base.broadcastable(x::AbstractInterval) = Ref(x)

bound(x::Bool) = x ? :closed : :open

include("inclusivity.jl")
include("endpoint.jl")
include("interval.jl")
include("anchoredinterval.jl")
include("description.jl")
include("plotting.jl")
include("deprecated.jl")

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
