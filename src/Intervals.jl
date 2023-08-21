module Intervals

using Dates
using Printf
using RecipesBase
using Serialization: Serialization, AbstractSerializer, deserialize
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

include("isfinite.jl")
include("endpoint.jl")
include("interval.jl")
include("interval_sets.jl")
include("anchoredinterval.jl")
include("parse.jl")
include("description.jl")
include("plotting.jl")
include("docstrings.jl")
include("deprecated.jl")
include("compat.jl")

export Bound,
       Closed,
       Open,
       Unbounded,
       AbstractInterval,
       Interval,
       IntervalSet,
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
       .., ≪, ≫, ⊆, ⊇, ⊈, ⊉,
       @i_cmd, @interval_cmd
end
