using Base: depwarn

# BEGIN Intervals 1.X.Y deprecations

function Base.convert(::Type{T}, interval::AnchoredInterval{P,T}) where {P,T}
    depwarn("`convert($T, interval::AnchoredInterval{P,$T})` is deprecated, use `anchor(interval)` instead.", :convert)
    anchor(interval)
end

for T in (:Date, :DateTime)
    @eval function Dates.$T(interval::AnchoredInterval{P, $T}) where P
        Base.depwarn("`$($T)(interval::AnchoredInterval{P,$($T)})` is deprecated, use `anchor(interval)` instead.", $(QuoteNode(T)))
        return anchor(interval)
    end
end


function Endpoint{T,D}(ep::T, included::Bool) where {T,D}
    B = bound(included)
    return Endpoint{T,D,B}(ep)
end

function LeftEndpoint(ep, included::Bool)
    B = bound(included)
    return LeftEndpoint{B}(ep)
end

function RightEndpoint(ep, included::Bool)
    B = bound(included)
    return RightEndpoint{B}(ep)
end

# intervals.jl
function Interval{T}(f, l, inc::Inclusivity) where T
    L = bound(first(inc))
    R = bound(last(inc))
    return Interval{T,L,R}(f, l)
end

function Interval{T}(f, l, x::Bool, y::Bool) where T
    L = bound(x)
    R = bound(y)
    return Interval{T,L,R}(f, l)
end

function Interval(f, l, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    return Interval{L,R}(f, l)
end

function Interval(f, l, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    return Interval{L,R}(f, l)
end

# anchoredintervals.jl
function AnchoredInterval{P,T}(anchor, inc::Inclusivity) where {P,T}
    L = bound(first(inc))
    R = bound(last(inc))
    return AnchoredInterval{P,T,L,R}(anchor)
end

function AnchoredInterval{P,T}(anchor, x::Bool, y::Bool) where {P,T}
    L = bound(x)
    R = bound(y)
    return AnchoredInterval{P,T,L,R}(anchor)
end

function AnchoredInterval{P}(anchor, inc::Inclusivity) where P
    L = bound(first(inc))
    R = bound(last(inc))
    return AnchoredInterval{P,L,R}(anchor)
end

function AnchoredInterval{P}(anchor, x::Bool, y::Bool) where P
    L = bound(x)
    R = bound(y)
    return AnchoredInterval{P,L,R}(anchor)
end

function HourEnding(anchor, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    return HourEnding{L,R}(anchor)
end

function HourEnding(anchor, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    return HourEnding{L,R}(anchor)
end

function HourBeginning(anchor, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    return HourBeginning{L,R}(anchor)
end

function HourBeginning(anchor, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    return HourBeginning{L,R}(anchor)
end

function HE(anchor, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    return HourEnding{L,R}(ceil(anchor, Hour))
end

function HE(anchor, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    return HourEnding{L,R}(ceil(anchor, Hour))
end

function HB(anchor, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    return HourBeginning{L,R}(floor(anchor, Hour))
end

function HB(anchor, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    return HourBeginning{L,R}(floor(anchor, Hour))
end

# END Intervals 1.X.Y deprecations
