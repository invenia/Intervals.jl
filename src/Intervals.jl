module Intervals

using Dates
using Printf
using RecipesBase
using TimeZones

using Dates: AbstractDateTime, value, coarserperiod

import Base: ⊆, ⊇, ⊈, ⊉, union, union!, merge

abstract type Bound end
struct Closed <: Bound end
struct Open <: Bound end

bound(x::Bool) = x ? Closed : Open

abstract type AbstractInterval{T, L <: Bound, R <: Bound} end

Base.eltype(::AbstractInterval{T}) where {T} = T
Base.broadcastable(x::AbstractInterval) = Ref(x)
bounds(x::AbstractInterval{T,L,R}) where {T,L,R} = (L, R)

include("endpoint.jl")
include("interval.jl")
include("anchoredinterval.jl")
include("description.jl")
include("plotting.jl")
include("deprecated.jl")

export Bound,
       Closed,
       Open,
       AbstractInterval,
       Interval,
       AnchoredInterval,
       HourEnding,
       HourBeginning,
       HE,
       HB,
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
