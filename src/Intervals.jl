module Intervals

using Dates
using Printf
using RecipesBase
using Serialization: Serialization, AbstractSerializer, deserialize
using TimeZones

using Dates: AbstractDateTime, value, coarserperiod

import Base: ⊆, ⊇, ⊈, ⊉, union, union!, merge

# TODO: Drop these types in favour of symbols when we switch to extending IntervalSets.jl
abstract type Bound end
abstract type Bounded <: Bound end
struct Closed <: Bounded end
struct Open <: Bounded end
struct Unbounded <: Bound end

bound_type(x::Bool) = x ? Closed : Open

# Methods for convert between int and tuple representations for space efficiency
# (Open, Closed) is 16 bytes while the integer represenation is only 1 byte.
# TODO: Convert types to symbols when we switch to extending IntervalSets.jl
bounds_int(l::Type{Open}, r::Type{Open}) = 0x00
bounds_int(l::Type{Closed}, r::Type{Open}) = 0x01
bounds_int(l::Type{Open}, r::Type{Closed}) = 0x02
bounds_int(l::Type{Closed}, r::Type{Closed}) = 0x03

bounds_types(x::Integer) = bounds_types(Val(UInt8(x)))
bounds_types(::Val{0x00}) = (Open, Open)
bounds_types(::Val{0x01}) = (Closed, Open)
bounds_types(::Val{0x02}) = (Open, Closed)
bounds_types(::Val{0x03}) = (Closed, Closed)

# Extension for backwards support of Unbounded endpoints to avoid changing existing logic
# TODO: Drop these in favour of the approach in IntervalSets.jl
bounds_int(l::Type{Open}, r::Type{Unbounded}) = 0x04
bounds_int(l::Type{Closed}, r::Type{Unbounded}) = 0x05
bounds_int(l::Type{Unbounded}, r::Type{Open}) = 0x06
bounds_int(l::Type{Unbounded}, r::Type{Closed}) = 0x07
bounds_int(l::Type{Unbounded}, r::Type{Unbounded}) = 0x08
bounds_types(::Val{0x04}) = (Open, Unbounded)
bounds_types(::Val{0x05}) = (Closed, Unbounded)
bounds_types(::Val{0x06}) = (Unbounded, Open)
bounds_types(::Val{0x07}) = (Unbounded, Closed)
bounds_types(::Val{0x08}) = (Unbounded, Unbounded)

abstract type AbstractInterval{T} end

Base.eltype(::AbstractInterval{T}) where {T} = T
Base.broadcastable(x::AbstractInterval) = Ref(x)
# Subtypes should implement:
# 1. first and last accessors
# 2. bounds_integer and bounds_types accessor

include("isfinite.jl")
include("endpoint.jl")
include("interval.jl")
# include("interval_sets.jl")
# include("anchoredinterval.jl")
include("parse.jl")
# include("description.jl")
#include("plotting.jl")
#include("docstrings.jl")
#include("deprecated.jl")
#include("compat.jl")

export Bound,
       Closed,
       Open,
       Unbounded,
       AbstractInterval,
       Interval,
       IntervalSet,
       # AnchoredInterval,
       # HourEnding,
       # HourBeginning,
       # HE,
       # HB,
       first,
       last,
       span,
       bounds_types,
       isclosed,
       # anchor,
       merge,
       union,
       union!,
       less_than_disjoint,
       greater_than_disjoint,
       superset,
       .., ≪, ≫, ⊆, ⊇, ⊈, ⊉
end
