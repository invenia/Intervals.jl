"""
    AnchoredInterval{P, T}(anchor::T, [inclusivity::Inclusivity]) where {P, T} -> AnchoredInterval{P, T}
    AnchoredInterval{P, T}(anchor::T, [closed_left::Bool, closed_right::Bool]) where {P, T} -> AnchoredInterval{P, T}

`AnchoredInterval` is a subtype of `AbstractInterval` that represents a non-iterable range
or span of values defined not by two endpoints but instead by a single `anchor` point and
the value type `P` which represents the size of the range. When `P` is positive, the
`anchor` represents the lesser endpoint (the beginning of the range); when `P` is negative,
the `anchor` represents the greater endpoint (the end of the range).

The interval represented by an `AnchoredInterval` value may be closed (both endpoints are
included in the interval), open (neither endpoint is included), or half-open. This openness
is defined by an `Inclusivity` value, which defaults to half-open (with the lesser endpoint
included for positive values of `P` and the greater endpoint included for negative values).

### Why?

`AnchoredIntervals` are most useful in cases where a single value is used to stand in for a
range of values. This happens most often with dates and times, where "HE15" is often used as
shorthand for (14:00..15:00].

To this end, `HourEnding` is a type alias for `AnchoredInterval{Hour(-1)}`. Similarly,
`HourBeginning` is a type alias for `AnchoredInterval{Hour(1)}`.

### Rounding

If `P` is a `Period`, the `anchor` provided is rounded up or down to the nearest `P`, as
appropriate, using `ceil` or `floor`. This means that
`AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 12, 30))` is equivalent to
`AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 13))`.

### Example

```julia
julia> AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 12))
HourEnding{DateTime}(2016-08-11T12:00:00, Inclusivity(false, true))

julia> AnchoredInterval{Day(1)}(DateTime(2016, 8, 11))
AnchoredInterval{1 day, DateTime}(2016-08-11T00:00:00, Inclusivity(true, false))

julia> AnchoredInterval{Minute(5)}(DateTime(2016, 8, 11, 12, 30, 5), true, true)
AnchoredInterval{5 minutes, DateTime}(2016-08-11T12:30:00, Inclusivity(true, true))
```

See also: [`Interval`](@ref), [`Inclusivity`](@ref)
"""
struct AnchoredInterval{P, T} <: AbstractInterval{T}
    anchor::T
    inclusivity::Inclusivity

    function AnchoredInterval{P, T}(anchor::T, inc::Inclusivity) where {P, T}
        if P isa Period && P != zero(P)
            anchor = P < zero(P) ? ceil(anchor, abs(P)) : floor(anchor, P)
        end
        return new(anchor, inc)
    end
end

# When an interval is anchored to the lesser endpoint, default to Inclusivity(false, true)
# When an interval is anchored to the greater endpoint, default to Inclusivity(true, false)
function AnchoredInterval{P, T}(i::T) where {P, T}
    return AnchoredInterval{P, T}(i::T, Inclusivity(P ≥ zero(P), P ≤ zero(P)))
end

AnchoredInterval{P}(i::T, inc::Inclusivity) where {P, T} = AnchoredInterval{P, T}(i, inc)
AnchoredInterval{P}(i::T) where {P, T} = AnchoredInterval{P, T}(i)

function AnchoredInterval{P, T}(i::T, x::Bool, y::Bool) where {P, T}
    return AnchoredInterval{P, T}(i, Inclusivity(x, y))
end

function AnchoredInterval{P}(i::T, x::Bool, y::Bool) where {P, T}
    return AnchoredInterval{P, T}(i, Inclusivity(x, y))
end

const HourEnding{T} = AnchoredInterval{Hour(-1), T}
HourEnding(i::T) where T = HourEnding{T}(i)
HourEnding(i::T, inc::Inclusivity) where T = HourEnding{T}(i, inc)
HourEnding(i::T, x::Bool, y::Bool) where T = HourEnding{T}(i, x, y)

const HourBeginning{T} = AnchoredInterval{Hour(1), T}
HourBeginning(i::T) where T = HourBeginning{T}(i)
HourBeginning(i::T, inc::Inclusivity) where T = HourBeginning{T}(i, inc)
HourBeginning(i::T, x::Bool, y::Bool) where T = HourBeginning{T}(i, x, y)

function Base.copy(x::AnchoredInterval{P, T}) where {P, T}
    return AnchoredInterval{P, T}(anchor(x), inclusivity(x))
end

##### ACCESSORS #####

Base.first(interval::AnchoredInterval{P}) where P = min(interval.anchor, interval.anchor+P)
Base.last(interval::AnchoredInterval{P}) where P = max(interval.anchor, interval.anchor+P)
anchor(interval::AnchoredInterval) = interval.anchor
span(interval::AnchoredInterval{P}) where P = abs(P)

##### CONVERSION #####

function Base.convert(::Type{Interval{T}}, interval::AnchoredInterval{P, T}) where {P, T}
    return Interval{T}(first(interval), last(interval), inclusivity(interval))
end

Base.convert(::Type{T}, interval::AnchoredInterval{P, T}) where {P, T} = anchor(interval)

# Date/DateTime attempt to convert to Int64 instead of falling back to convert(T, ...)
Base.Date(interval::AnchoredInterval{P, Date}) where P = convert(Date, interval)
Base.DateTime(interval::AnchoredInterval{P, DateTime}) where P = convert(DateTime, interval)

##### DISPLAY #####

Base.show(io::IO, ::Type{HourEnding}) = print(io, "HourEnding{T}")
Base.show(io::IO, ::Type{HourBeginning}) = print(io, "HourBeginning{T}")

Base.show(io::IO, ::Type{HourEnding{T}}) where T = print(io, "HourEnding{$T}")
Base.show(io::IO, ::Type{HourBeginning{T}}) where T = print(io, "HourBeginning{$T}")

function Base.show(io::IO, ::Type{AnchoredInterval{P, T}}) where {P, T}
    print(io, "AnchoredInterval{$P, $T}")
end

function Base.show(io::IO, interval::T) where T <: AnchoredInterval
    if get(io, :compact, false)
        print(io, interval)
    else
        print(io, "$T(")
        show(io, anchor(interval))
        print(io, ", ")
        show(io, inclusivity(interval))
        print(io, ")")
    end
end

function Base.print(io::IO, interval::AnchoredInterval{P, T}) where {P, T <: TimeType}
    # Print to io in order to keep properties like :limit and :compact
    if get(io, :compact, false)
        io = IOContext(io, :limit=>true)
    end

    print(io, summary(interval))
end

##### ARITHMETIC #####

function Base.:+(a::AnchoredInterval{P, T}, b::T) where {P, T}
    return AnchoredInterval{P, T}(anchor(a) + b, inclusivity(a))
end

function Base.:+(a::AnchoredInterval{P, Char}, b::Integer) where P
    return AnchoredInterval{P, Char}(anchor(a) + b, inclusivity(a))
end

function Base.:+(a::AnchoredInterval{P, T}, b::Period) where {P, T <: TimeType}
    return AnchoredInterval{P, T}(anchor(a) + b, inclusivity(a))
end

Base.:+(a::T, b::AnchoredInterval{P, T}) where {P, T} = b + a
Base.:+(a::Integer, b::AnchoredInterval{P, Char}) where P = b + a
Base.:+(a::Period, b::AnchoredInterval{P, <:TimeType}) where P = b + a

Base.:-(a::AnchoredInterval{P, T}, b::T) where {P, T} = a + -b
Base.:-(a::AnchoredInterval{P, Char}, b::Integer) where P = a + -b
Base.:-(a::AnchoredInterval{P, <:TimeType}, b::Period) where P = a + -b

# Required for StepRange{<:AnchoredInterval}
Base.:-(a::AnchoredInterval, b::AnchoredInterval) = anchor(a) - anchor(b)

##### RANGE #####

# Required for StepRange{<:AnchoredInterval}
function Base.steprem(a::AnchoredInterval{P, T}, b::AnchoredInterval{P, T}, c) where {P, T}
    return Base.steprem(anchor(a), anchor(b), c)
end

# Infer step for two-argument StepRange{<:AnchoredInterval}
function Base.colon(start::AnchoredInterval{P, T}, stop::AnchoredInterval{P, T}) where {P,T}
    return colon(start, abs(P), stop)
end

function Base.length(r::StepRange{<:AnchoredInterval})
    return length(anchor(r.start):r.step:anchor(r.stop))
end

##### SET OPERATIONS #####

function Base.isempty(interval::AnchoredInterval{P, T}) where {P, T}
    return P == zero(P) && !isclosed(interval)
end
