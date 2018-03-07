using Base.Dates: value, coarserperiod

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

While the user may expect an `HourEnding` or `HourBeginning` value to be anchored to a
specific hour, the constructor makes no guarantees that the anchor provided is rounded:

```julia
julia> HourEnding(DateTime(2016, 8, 11, 2, 30))
HourEnding{DateTime}(2016-08-11T02:30:00, Inclusivity(false, true))
```

The `HE` and `HB` pseudoconstructors round the input up or down to the nearest hour, as
appropriate:

```julia
julia> HE(DateTime(2016, 8, 11, 2, 30))
HourEnding{DateTime}(2016-08-11T03:00:00, Inclusivity(false, true))

julia> HB(DateTime(2016, 8, 11, 2, 30))
HourBeginning{DateTime}(2016-08-11T02:00:00, Inclusivity(true, false))
```

### Example

```julia
julia> AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 12))
HourEnding{DateTime}(2016-08-11T12:00:00, Inclusivity(false, true))

julia> AnchoredInterval{Day(1)}(DateTime(2016, 8, 11))
AnchoredInterval{1 day, DateTime}(2016-08-11T00:00:00, Inclusivity(true, false))

julia> AnchoredInterval{Minute(5)}(DateTime(2016, 8, 11, 12, 30), true, true)
AnchoredInterval{5 minutes, DateTime}(2016-08-11T12:30:00, Inclusivity(true, true))
```

See also: [`Interval`](@ref), [`Inclusivity`](@ref), [`HE`](@ref), [`HB`](@ref)
"""
struct AnchoredInterval{P, T} <: AbstractInterval{T}
    anchor::T
    inclusivity::Inclusivity
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

const HourEnding{T} = AnchoredInterval{Hour(-1), T} where T <: TimeType
HourEnding(a::T, args...) where T = HourEnding{T}(a, args...)

const HourBeginning{T} = AnchoredInterval{Hour(1), T} where T <: TimeType
HourBeginning(a::T, args...) where T = HourBeginning{T}(a, args...)

"""
    HE(anchor, args...) -> HourEnding

`HE` is a pseudoconstructor for `HourEnding` that rounds the anchor provided up to the
nearest hour.
"""
HE(a, args...) = HourEnding(ceil(a, Hour), args...)

"""
    HB(anchor, args...) -> HourBeginning

`HB` is a pseudoconstructor for `HourBeginning` that rounds the anchor provided down to the
nearest hour.
"""
HB(a, args...) = HourBeginning(floor(a, Hour), args...)

function Base.copy(x::AnchoredInterval{P, T}) where {P, T}
    return AnchoredInterval{P, T}(anchor(x), inclusivity(x))
end

##### ACCESSORS #####

Base.first(interval::AnchoredInterval{P}) where P = min(interval.anchor, interval.anchor+P)
Base.last(interval::AnchoredInterval{P}) where P = max(interval.anchor, interval.anchor+P)
anchor(interval::AnchoredInterval) = interval.anchor
span(interval::AnchoredInterval{P}) where P = abs(P)

##### CONVERSION #####

function Base.convert(::Type{Interval}, interval::AnchoredInterval{P, T}) where {P, T}
    return Interval{T}(first(interval), last(interval), inclusivity(interval))
end

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

Base.show(io::IO, ::Type{HourEnding{T}}) where T <: TimeType = print(io, "HourEnding{$T}")
Base.show(io::IO, ::Type{HourBeginning{T}}) where T <: TimeType = print(io, "HourBeginning{$T}")

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

    print(io, description(interval))
end

##### ARITHMETIC #####

Base.:+(a::T, b) where {T <: AnchoredInterval} = T(anchor(a) + b, inclusivity(a))

Base.:+(a, b::AnchoredInterval) = b + a
Base.:-(a::AnchoredInterval, b) = a + -b

# Required for StepRange{<:AnchoredInterval}
Base.:-(a::AnchoredInterval, b::AnchoredInterval) = anchor(a) - anchor(b)

Base.:-(a::T, b::AnchoredInterval{P, T}) where {P, T <: Number} = a + -b

function Base.:-(a::AnchoredInterval{P, T}) where {P, T <: Number}
    inc = inclusivity(a)
    AnchoredInterval{-P, T}(-anchor(a), Inclusivity(last(inc), first(inc)))
end

##### RANGE #####

# Required for StepRange{<:AnchoredInterval}
function Base.steprem(a::T, b::T, c) where {T <: AnchoredInterval}
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

function Base.intersect(a::AnchoredInterval{P, T}, b::AnchoredInterval{Q, T}) where {P,Q,T}
    interval = invoke(intersect, Tuple{AbstractInterval{T}, AbstractInterval{T}}, a, b)

    sp = isa(P, Period) ? canonicalize(typeof(P), span(interval)) : span(interval)
    if P ≤ zero(P)
        anchor = last(interval)
        new_P = -sp
    else
        anchor = first(interval)
        new_P = sp
    end

    return AnchoredInterval{new_P, T}(anchor, inclusivity(interval))
end

##### UTILITIES #####

function canonicalize(target_type::Type{<:Period}, p::P) where P <: Period
    Q, max_val = coarserperiod(P)
    if (value(p) % max_val == 0) && (max_val > 1)
        p = canonicalize(target_type, convert(Q, p))
    end
    return p
end

canonicalize(target_type::Type{P}, p::P) where P <: Period = p
