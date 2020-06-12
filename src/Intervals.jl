module Intervals

using Dates
using Printf
using RecipesBase
using TimeZones

using Dates: AbstractDateTime, value, coarserperiod

import Base: ⊆, ⊇, ⊈, ⊉, union, union!, merge

abstract type Bound end
abstract type Bounded <: Bound end
struct Closed <: Bounded end
struct Open <: Bounded end
struct Unbounded <: Bound end

bound_type(x::Bool) = x ? Closed : Open

abstract type AbstractInterval{T, L <: Bound, R <: Bound} end

Base.eltype(::AbstractInterval{T}) where {T} = T
Base.broadcastable(x::AbstractInterval) = Ref(x)
bounds_types(x::AbstractInterval{T,L,R}) where {T,L,R} = (L, R)

const SPAN_NON_BOUNDED_EXCEPTION = DomainError(
    "unbounded endpoint(s)",
    "Unable to determine the span of an non-bounded interval",
)

include("endpoint.jl")
include("interval.jl")
include("anchoredinterval.jl")
include("description.jl")
include("plotting.jl")
include("docstrings.jl")
include("deprecated.jl")

export Bound,
       Closed,
       Open,
       Unbounded,
       AbstractInterval,
       Interval,
       AnchoredInterval,
       HourEnding,
       HourBeginning,
       HE,
       HB,
       first,
       last,
       span,
       bounds_types,
       isclosed,
       anchor,
       merge,
       union,
       union!,
       less_than_disjoint,
       greater_than_disjoint,
       superset,
       .., ≪, ≫, ⊆, ⊇, ⊈, ⊉
end
