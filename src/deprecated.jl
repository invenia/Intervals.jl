using Base: depwarn

# BEGIN Intervals 1.X.Y deprecations

function Base.convert(::Type{T}, interval::AnchoredInterval{P,T}) where {P,T}
    depwarn("`convert($T, interval::AnchoredInterval{P,$T})` is deprecated, use `anchor(interval)` instead.", :convert)
    anchor(interval)
end

for T in (:Date, :DateTime)
    @eval function Dates.$T(interval::AnchoredInterval{P, $T}) where P
        depwarn("`$($T)(interval::AnchoredInterval{P,$($T)})` is deprecated, use `anchor(interval)` instead.", $(QuoteNode(T)))
        return anchor(interval)
    end
end


function Endpoint{T,D}(ep::T, included::Bool) where {T,D}
    B = bound(included)
    depwarn("`Endpoint{T,D}(ep, $included)` is deprecated, use `Endpoint{T,D,$(repr(B))}(ep)` instead.", :Endpoint)
    return Endpoint{T,D,B}(ep)
end

function LeftEndpoint(ep, included::Bool)
    B = bound(included)
    depwarn("`LeftEndpoint(ep, $included)` is deprecated, use `LeftEndpoint{$(repr(B))}(ep)` instead.", :LeftEndpoint)
    return LeftEndpoint{B}(ep)
end

function RightEndpoint(ep, included::Bool)
    B = bound(included)
    depwarn("`RightEndpoint(ep, $included)` is deprecated, use `RightEndpoint{$(repr(B))}(ep)` instead.", :RightEndpoint)
    return RightEndpoint{B}(ep)
end

# intervals.jl
function Interval{T}(f, l, inc::Inclusivity) where T
    L = bound(first(inc))
    R = bound(last(inc))
    depwarn("`Interval{T}(f, l, $(repr(inc)))` is deprecated, use `Interval{T,$(repr(L)),$(repr(R))}(f, l)` instead.", :Interval)
    return Interval{T,L,R}(f, l)
end

function Interval{T}(f, l, x::Bool, y::Bool) where T
    L = bound(x)
    R = bound(y)
    depwarn("`Interval{T}(f, l, $x, $y)` is deprecated, use `Interval{T,$(repr(L)),$(repr(R))}(f, l)` instead.", :Interval)
    return Interval{T,L,R}(f, l)
end

function Interval(f, l, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    depwarn("`Interval(f, l, $(repr(inc)))` is deprecated, use `Interval{T,$(repr(L)),$(repr(R))}(f, l)` instead.", :Interval)
    return Interval{L,R}(f, l)
end

function Interval(f, l, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    depwarn("`Interval(f, l, $x, $y)` is deprecated, use `Interval{T,$(repr(L)),$(repr(R))}(f, l)` instead.", :Interval)
    return Interval{L,R}(f, l)
end

# anchoredintervals.jl
function AnchoredInterval{P,T}(anchor, inc::Inclusivity) where {P,T}
    L = bound(first(inc))
    R = bound(last(inc))
    depwarn("`AnchoredInterval{P,T}(anchor, $(repr(inc)))` is deprecated, use `AnchoredInterval{P,T,$(repr(L)),$(repr(R))}(anchor)` instead.", :AnchoredInterval)
    return AnchoredInterval{P,T,L,R}(anchor)
end

function AnchoredInterval{P,T}(anchor, x::Bool, y::Bool) where {P,T}
    L = bound(x)
    R = bound(y)
    depwarn("`AnchoredInterval{P,T}(anchor, $x, $y)` is deprecated, use `AnchoredInterval{P,T,$(repr(L)),$(repr(R))}(anchor)` instead.", :AnchoredInterval)
    return AnchoredInterval{P,T,L,R}(anchor)
end

function AnchoredInterval{P}(anchor, inc::Inclusivity) where P
    L = bound(first(inc))
    R = bound(last(inc))
    depwarn("`AnchoredInterval{P}(anchor, $(repr(inc)))` is deprecated, use `AnchoredInterval{P,$(repr(L)),$(repr(R))}(anchor)` instead.", :AnchoredInterval)
    return AnchoredInterval{P,L,R}(anchor)
end

function AnchoredInterval{P}(anchor, x::Bool, y::Bool) where P
    L = bound(x)
    R = bound(y)
    depwarn("`AnchoredInterval{P}(anchor, $x, $y)` is deprecated, use `AnchoredInterval{P,$(repr(L)),$(repr(R))}(anchor)` instead.", :AnchoredInterval)
    return AnchoredInterval{P,L,R}(anchor)
end

function HourEnding(anchor, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    depwarn("`HourEnding(anchor, $x, $y)` is deprecated, use `HourEnding{$(repr(L)),$(repr(R))}(anchor)` instead.", :HourEnding)
    return HourEnding{L,R}(anchor)
end

function HourEnding(anchor, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    depwarn("`HourEnding(anchor, $(repr(inc)))` is deprecated, use `HourEnding{$(repr(L)),$(repr(R))}(anchor)` instead.", :HourEnding)
    return HourEnding{L,R}(anchor)
end

function HourBeginning(anchor, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    depwarn("`HourBeginning(anchor, $x, $y)` is deprecated, use `HourBeginning{$(repr(L)),$(repr(R))}(anchor)` instead.", :HourBeginning)
    return HourBeginning{L,R}(anchor)
end

function HourBeginning(anchor, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    depwarn("`HourBeginning(anchor, $(repr(inc)))` is deprecated, use `HourBeginning{$(repr(L)),$(repr(R))}(anchor)` instead.", :HourBeginning)
    return HourBeginning{L,R}(anchor)
end

function HE(anchor, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    if !x && y
        depwarn("`HE(anchor, $x, $y)` is deprecated, use `HE(anchor)` instead.", :HE)
    else
        depwarn("`HE(anchor, $x, $y)` is deprecated, use `HourEnding{$(repr(L)),$(repr(R))}(ceil(anchor, Hour))` instead.", :HE)
    end
    return HourEnding{L,R}(ceil(anchor, Hour))
end

function HE(anchor, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    if !first(inc) && last(inc)
        depwarn("`HE(anchor, $(repr(inc)))` is deprecated, use `HE(anchor)` instead.", :HE)
    else
        depwarn("`HE(anchor, $(repr(inc)))` is deprecated, use `HourEnding{$(repr(L)),$(repr(R))}(ceil(anchor, Hour))` instead.", :HE)
    end
    return HourEnding{L,R}(ceil(anchor, Hour))
end

function HB(anchor, x::Bool, y::Bool)
    L = bound(x)
    R = bound(y)
    if x && !y
        depwarn("`HB(anchor, $x, $y)` is deprecated, use `HB(anchor)` instead.", :HB)
    else
        depwarn("`HB(anchor, $x, $y)` is deprecated, use `HourBeginning{$(repr(L)),$(repr(R))}(floor(anchor, Hour))` instead.", :HB)
    end
    return HourBeginning{L,R}(floor(anchor, Hour))
end

function HB(anchor, inc::Inclusivity)
    L = bound(first(inc))
    R = bound(last(inc))
    if first(inc) && !last(inc)
        depwarn("`HB(anchor, $(repr(inc)))` is deprecated, use `HB(anchor)` instead.", :HB)
    else
        depwarn("`HB(anchor, $(repr(inc)))` is deprecated, use `HourBeginning{$(repr(L)),$(repr(R))}(floor(anchor, Hour))` instead.", :HB)
    end
    return HourBeginning{L,R}(floor(anchor, Hour))
end

# END Intervals 1.X.Y deprecations
