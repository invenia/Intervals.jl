using Base: @deprecate, depwarn
import Dates: Date, DateTime

# BEGIN Intervals 1.X.Y deprecations

export Inclusivity, inclusivity
include("inclusivity.jl")

@deprecate Date(interval::Interval{Date}) convert(Date, interval)
@deprecate DateTime(interval::Interval{DateTime}) convert(DateTime, interval)
@deprecate Date(interval::AnchoredInterval{P, Date} where P) convert(Date, interval)
@deprecate DateTime(interval::AnchoredInterval{P, DateTime} where P) convert(DateTime, interval)


function Endpoint{T,D}(ep::T, included::Bool) where {T,D}
    B = bound_type(included)
    depwarn("`Endpoint{T,D}(ep, $included)` is deprecated, use `Endpoint{T,D,$(repr(B))}(ep)` instead.", :Endpoint)
    return Endpoint{T,D,B}(ep)
end

function LeftEndpoint(ep, included::Bool)
    B = bound_type(included)
    depwarn("`LeftEndpoint(ep, $included)` is deprecated, use `LeftEndpoint{$(repr(B))}(ep)` instead.", :LeftEndpoint)
    return LeftEndpoint{B}(ep)
end

function RightEndpoint(ep, included::Bool)
    B = bound_type(included)
    depwarn("`RightEndpoint(ep, $included)` is deprecated, use `RightEndpoint{$(repr(B))}(ep)` instead.", :RightEndpoint)
    return RightEndpoint{B}(ep)
end

# intervals.jl
function Interval{T,L,R}(f::T, l::T, inc::Inclusivity) where {T,L,R}
    left_inc = bound_type(first(inc))
    right_inc = bound_type(last(inc))
    if L !== left_inc || R !== right_inc
        throw(ArgumentError("Specified inclusivity ($(repr(left_inc)), $(repr(right_inc))) doesn't match bound types ($(repr(L)), $(repr(R)))"))
    end
    depwarn("`Interval{T,$(repr(L)),$(repr(R))}(f, l, $(repr(inc)))` is deprecated, use `Interval{T,$(repr(L)),$(repr(R))}(f, l)` instead.", :Interval)
    return Interval{T,L,R}(f, l)
end

function Interval{T,L,R}(f, l, inc::Inclusivity) where {T,L,R}
    # Using depwarn from next call
    return Interval{T,L,R}(convert(T, f), convert(T, l), inc)
end

function Interval{T}(f, l, inc::Inclusivity) where T
    L = bound_type(first(inc))
    R = bound_type(last(inc))
    depwarn("`Interval{T}(f, l, $(repr(inc)))` is deprecated, use `Interval{T,$(repr(L)),$(repr(R))}(f, l)` instead.", :Interval)
    return Interval{T,L,R}(f, l)
end

function Interval{T}(f, l, x::Bool, y::Bool) where T
    L = bound_type(x)
    R = bound_type(y)
    depwarn("`Interval{T}(f, l, $x, $y)` is deprecated, use `Interval{T,$(repr(L)),$(repr(R))}(f, l)` instead.", :Interval)
    return Interval{T,L,R}(f, l)
end

function Interval(f, l, inc::Inclusivity)
    L = bound_type(first(inc))
    R = bound_type(last(inc))
    depwarn("`Interval(f, l, $(repr(inc)))` is deprecated, use `Interval{T,$(repr(L)),$(repr(R))}(f, l)` instead.", :Interval)
    return Interval{L,R}(f, l)
end

function Interval(f, l, x::Bool, y::Bool)
    L = bound_type(x)
    R = bound_type(y)
    depwarn("`Interval(f, l, $x, $y)` is deprecated, use `Interval{T,$(repr(L)),$(repr(R))}(f, l)` instead.", :Interval)
    return Interval{L,R}(f, l)
end

function inclusivity(interval::AbstractInterval{T,L,R}) where {T,L,R}
    depwarn("`inclusivity(interval)` is deprecated and has no direct replacement. See `bounds_types(interval)` for similar functionality.", :inclusivity)
    return Inclusivity(L === Closed, R === Closed; ignore_depwarn=true)
end

# anchoredintervals.jl
function AnchoredInterval{P,T,L,R}(anchor::T, inc::Inclusivity) where {P,T,L,R}
    left_inc = bound_type(first(inc))
    right_inc = bound_type(last(inc))
    if L !== left_inc || R !== right_inc
        throw(ArgumentError("Specified inclusivity ($(repr(left_inc)), $(repr(right_inc))) doesn't match bound types ($(repr(L)), $(repr(R)))"))
    end
    depwarn("`AnchoredInterval{P,T,$(repr(L)),$(repr(R))}(anchor, $(repr(inc)))` is deprecated, use `AnchoredInterval{P,T,$(repr(L)),$(repr(R))}(anchor)` instead.", :AnchoredInterval)
    return AnchoredInterval{P,T,L,R}(anchor)
end

function AnchoredInterval{P,T,L,R}(anchor, inc::Inclusivity) where {P,T,L,R}
    # Using depwarn from next call
    return AnchoredInterval{P,T,L,R}(convert(T, anchor), inc)
end

function AnchoredInterval{P,T}(anchor, inc::Inclusivity) where {P,T}
    L = bound_type(first(inc))
    R = bound_type(last(inc))
    depwarn("`AnchoredInterval{P,T}(anchor, $(repr(inc)))` is deprecated, use `AnchoredInterval{P,T,$(repr(L)),$(repr(R))}(anchor)` instead.", :AnchoredInterval)
    return AnchoredInterval{P,T,L,R}(anchor)
end

function AnchoredInterval{P,T}(anchor, x::Bool, y::Bool) where {P,T}
    L = bound_type(x)
    R = bound_type(y)
    depwarn("`AnchoredInterval{P,T}(anchor, $x, $y)` is deprecated, use `AnchoredInterval{P,T,$(repr(L)),$(repr(R))}(anchor)` instead.", :AnchoredInterval)
    return AnchoredInterval{P,T,L,R}(anchor)
end

function AnchoredInterval{P}(anchor, inc::Inclusivity) where P
    L = bound_type(first(inc))
    R = bound_type(last(inc))
    depwarn("`AnchoredInterval{P}(anchor, $(repr(inc)))` is deprecated, use `AnchoredInterval{P,$(repr(L)),$(repr(R))}(anchor)` instead.", :AnchoredInterval)
    return AnchoredInterval{P,L,R}(anchor)
end

function AnchoredInterval{P}(anchor, x::Bool, y::Bool) where P
    L = bound_type(x)
    R = bound_type(y)
    depwarn("`AnchoredInterval{P}(anchor, $x, $y)` is deprecated, use `AnchoredInterval{P,$(repr(L)),$(repr(R))}(anchor)` instead.", :AnchoredInterval)
    return AnchoredInterval{P,L,R}(anchor)
end

function HourEnding(anchor, x::Bool, y::Bool)
    L = bound_type(x)
    R = bound_type(y)
    depwarn("`HourEnding(anchor, $x, $y)` is deprecated, use `HourEnding{$(repr(L)),$(repr(R))}(anchor)` instead.", :HourEnding)
    return HourEnding{L,R}(anchor)
end

function HourEnding(anchor, inc::Inclusivity)
    L = bound_type(first(inc))
    R = bound_type(last(inc))
    depwarn("`HourEnding(anchor, $(repr(inc)))` is deprecated, use `HourEnding{$(repr(L)),$(repr(R))}(anchor)` instead.", :HourEnding)
    return HourEnding{L,R}(anchor)
end

function HourBeginning(anchor, x::Bool, y::Bool)
    L = bound_type(x)
    R = bound_type(y)
    depwarn("`HourBeginning(anchor, $x, $y)` is deprecated, use `HourBeginning{$(repr(L)),$(repr(R))}(anchor)` instead.", :HourBeginning)
    return HourBeginning{L,R}(anchor)
end

function HourBeginning(anchor, inc::Inclusivity)
    L = bound_type(first(inc))
    R = bound_type(last(inc))
    depwarn("`HourBeginning(anchor, $(repr(inc)))` is deprecated, use `HourBeginning{$(repr(L)),$(repr(R))}(anchor)` instead.", :HourBeginning)
    return HourBeginning{L,R}(anchor)
end

function HE(anchor, x::Bool, y::Bool)
    L = bound_type(x)
    R = bound_type(y)
    if !x && y
        depwarn("`HE(anchor, $x, $y)` is deprecated, use `HE(anchor)` instead.", :HE)
    else
        depwarn("`HE(anchor, $x, $y)` is deprecated, use `HourEnding{$(repr(L)),$(repr(R))}(ceil(anchor, Hour))` instead.", :HE)
    end
    return HourEnding{L,R}(ceil(anchor, Hour))
end

function HE(anchor, inc::Inclusivity)
    L = bound_type(first(inc))
    R = bound_type(last(inc))
    if !first(inc) && last(inc)
        depwarn("`HE(anchor, $(repr(inc)))` is deprecated, use `HE(anchor)` instead.", :HE)
    else
        depwarn("`HE(anchor, $(repr(inc)))` is deprecated, use `HourEnding{$(repr(L)),$(repr(R))}(ceil(anchor, Hour))` instead.", :HE)
    end
    return HourEnding{L,R}(ceil(anchor, Hour))
end

function HB(anchor, x::Bool, y::Bool)
    L = bound_type(x)
    R = bound_type(y)
    if x && !y
        depwarn("`HB(anchor, $x, $y)` is deprecated, use `HB(anchor)` instead.", :HB)
    else
        depwarn("`HB(anchor, $x, $y)` is deprecated, use `HourBeginning{$(repr(L)),$(repr(R))}(floor(anchor, Hour))` instead.", :HB)
    end
    return HourBeginning{L,R}(floor(anchor, Hour))
end

function HB(anchor, inc::Inclusivity)
    L = bound_type(first(inc))
    R = bound_type(last(inc))
    if first(inc) && !last(inc)
        depwarn("`HB(anchor, $(repr(inc)))` is deprecated, use `HB(anchor)` instead.", :HB)
    else
        depwarn("`HB(anchor, $(repr(inc)))` is deprecated, use `HourBeginning{$(repr(L)),$(repr(R))}(floor(anchor, Hour))` instead.", :HB)
    end
    return HourBeginning{L,R}(floor(anchor, Hour))
end

# END Intervals 1.X.Y deprecations
