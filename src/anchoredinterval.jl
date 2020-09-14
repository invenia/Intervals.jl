"""
    AnchoredInterval{P,T,L,R}

`AnchoredInterval` is a subtype of `AbstractInterval` that represents a non-iterable range
or span of values defined not by two endpoints but instead by a single `anchor` point and
the value type `P` which represents the size of the range. When `P` is positive, the
`anchor` represents the lesser endpoint (the beginning of the range); when `P` is negative,
the `anchor` represents the greater endpoint (the end of the range).

The interval represented by an `AnchoredInterval` value may be closed (both endpoints are
included in the interval), open (neither endpoint is included), or half-open. This openness
is defined by the bounds types `L` and `R`, which defaults to half-open (with the lesser
endpoint included for positive values of `P` and the greater endpoint included for negative
values).

### Why?

`AnchoredIntervals` are most useful in cases where a single value is used to stand in for a
range of values. This happens most often with dates and times, where "HE15" is often used as
shorthand for (14:00..15:00].

To this end, `HourEnding` is a type alias for `AnchoredInterval{Hour(-1)}`. Similarly,
`HourBeginning` is a type alias for `AnchoredInterval{Hour(1)}`.

### Rounding

While the user may expect an `HourEnding` or `HourBeginning` value to be anchored to a
specific hour, the constructor makes no guarantees that the anchor provided is rounded:

```jldoctest; setup = :(using Intervals, Dates), filter = r"AnchoredInterval\\{(Day|Hour|Minute)\\(-?\\d+\\),|Hour(Ending|Beginning)\\{"
julia> HourEnding(DateTime(2016, 8, 11, 2, 30))
AnchoredInterval{Hour(-1),DateTime,Open,Closed}(DateTime("2016-08-11T02:30:00"))
```

The `HE` and `HB` pseudoconstructors round the input up or down to the nearest hour, as
appropriate:

```jldoctest; setup = :(using Intervals, Dates), filter = r"AnchoredInterval\\{(Day|Hour|Minute)\\(-?\\d+\\),|Hour(Ending|Beginning)\\{"
julia> HE(DateTime(2016, 8, 11, 2, 30))
AnchoredInterval{Hour(-1),DateTime,Open,Closed}(DateTime("2016-08-11T03:00:00"))

julia> HB(DateTime(2016, 8, 11, 2, 30))
AnchoredInterval{Hour(1),DateTime,Closed,Open}(DateTime("2016-08-11T02:00:00"))
```

### Example

```jldoctest; setup = :(using Intervals, Dates), filter = r"AnchoredInterval\\{(Day|Hour|Minute)\\(-?\\d+\\),|Hour(Ending|Beginning)\\{"
julia> AnchoredInterval{Hour(-1)}(DateTime(2016, 8, 11, 12))
AnchoredInterval{Hour(-1),DateTime,Open,Closed}(DateTime("2016-08-11T12:00:00"))

julia> AnchoredInterval{Day(1)}(DateTime(2016, 8, 11))
AnchoredInterval{Day(1),DateTime,Closed,Open}(DateTime("2016-08-11T00:00:00"))

julia> AnchoredInterval{Minute(5),Closed,Closed}(DateTime(2016, 8, 11, 12, 30))
AnchoredInterval{Minute(5),DateTime,Closed,Closed}(DateTime("2016-08-11T12:30:00"))
```

See also: [`Interval`](@ref), [`HE`](@ref), [`HB`](@ref)
"""
struct AnchoredInterval{P, T, L <: Bounded, R <: Bounded} <: AbstractInterval{T,L,R}
    anchor::T

    function AnchoredInterval{P,T,L,R}(anchor::T) where {P, T, L <: Bounded, R <: Bounded}
        # A valid interval requires that neither endpoints or the span are nan. Typically,
        # we use `left <= right` to ensure a valid interval but for `AnchoredInterval`s
        # computing the other endpoint requires `anchor + P` which may fail with certain
        # types (e.g. ambiguous or non-existent ZonedDateTimes).
        #
        # We can skip computing the other endpoint if both the anchor and span are finite as
        # this ensures the computed endpoint is also finite.
        if !isfinite(anchor) || !isfinite(P)
            left, right = sign(P) < 0 ? (anchor + P, anchor) : (anchor, anchor + P)

            if !(left <= right)
                msg = if sign(P) < 0
                    "Unable to represent a right-anchored interval where the " *
                    "left ($anchor + $P) > right ($anchor)"
                else
                    "Unable to represent a left-anchored interval where the " *
                    "left ($anchor) > right ($anchor + $P)"
                end
                throw(ArgumentError(msg))
            end
        end

        return new{P,T,L,R}(anchor)
    end
end

function AnchoredInterval{P,T,L,R}(interval::AnchoredInterval{P,T,L,R}) where {P,T,L,R}
    AnchoredInterval{P,T,L,R}(interval.anchor)
end

function AnchoredInterval{P,T,L,R}(anchor) where {P,T,L,R}
    AnchoredInterval{P,T,L,R}(convert(T, anchor))
end

AnchoredInterval{P,L,R}(anchor::T) where {P,T,L,R} = AnchoredInterval{P,T,L,R}(anchor)

# When an interval is anchored to the lesser endpoint, default to Inclusivity(false, true)
# When an interval is anchored to the greater endpoint, default to Inclusivity(true, false)
function AnchoredInterval{P,T}(anchor) where {P,T}
    L = bound_type(P ≥ zero(P))
    R = bound_type(P ≤ zero(P))
    return AnchoredInterval{P,T,L,R}(anchor)
end

AnchoredInterval{P}(anchor::T) where {P,T} = AnchoredInterval{P,T}(anchor)

# Note: Ideally we would define the restriction `T <: TimeType` but doing so interferes with
# the `HourEnding{L,R}` constructor.
"""
    HourEnding{T<:TimeType, L, R} <: AbstractInterval{T}

A type alias for `AnchoredInterval{Hour(-1), T}` which is used to denote a 1-hour period of
time which ends at a time instant (of type `T`).
"""
const HourEnding{T,L,R} = AnchoredInterval{Hour(-1), T, L, R} where {T, L <: Bounded, R <: Bounded}
HourEnding(anchor::T) where T = HourEnding{T}(anchor)

# Note: Ideally we would define the restriction `T <: TimeType` but doing so interferes with
# the `HourBeginning{L,R}` constructor.
"""
    HourBeginning{T<:TimeType, L, R} <: AbstractInterval{T}

A type alias for `AnchoredInterval{Hour(1), T}` which is used to denote a 1-hour period of
time which begins at a time instant (of type `T`).
"""
const HourBeginning{T,L,R} = AnchoredInterval{Hour(1), T, L, R} where {T, L <: Bounded, R <: Bounded}
HourBeginning(anchor::T) where T = HourBeginning{T}(anchor)

"""
    HE(anchor) -> HourEnding

`HE` is a pseudoconstructor for [`HourEnding`](@ref) that rounds the anchor provided up to the
nearest hour.
"""
HE(anchor) = HourEnding(ceil(anchor, Hour))

"""
    HB(anchor) -> HourBeginning

`HB` is a pseudoconstructor for [`HourBeginning`](@ref) that rounds the anchor provided down to the
nearest hour.
"""
HB(anchor) = HourBeginning(floor(anchor, Hour))

function Base.copy(x::AnchoredInterval{P,T,L,R}) where {P,T,L,R}
    return AnchoredInterval{P,T,L,R}(anchor(x))
end

##### ACCESSORS #####

# We would typically compute `first` and `last` using `min` and `max` respectively, but we
# can get unexpected behaviour if adding the span to the anchor endpoint produces a value
# that is no longer comparable (e.g., `NaN`).

function Base.first(interval::AnchoredInterval{P}) where P
    P < zero(P) ? (interval.anchor + P) : (interval.anchor)
end

function Base.last(interval::AnchoredInterval{P}) where P
    P < zero(P) ? (interval.anchor) : (interval.anchor + P)
end

anchor(interval::AnchoredInterval) = interval.anchor
span(interval::AnchoredInterval{P}) where P = abs(P)

##### CONVERSION #####

# Allows an interval to be converted to a scalar when the set contained by the interval only
# contains a single element.
function Base.convert(::Type{T}, interval::AnchoredInterval{P,T}) where {P,T}
    if isclosed(interval) && (iszero(P) || first(interval) == last(interval))
        return first(interval)
    else
        # Remove deprecation in version 2.0.0
        depwarn(
            "`convert(T, interval::AnchoredInterval{P,T})` is deprecated for " *
            "intervals which are not closed with coinciding endpoints. " *
            "Use `anchor(interval)` instead.",
            :convert,
        )
        return anchor(interval)

        # TODO: For when deprecation is removed
        # throw(DomainError(interval, "The interval is not closed with coinciding endpoints"))
    end
end

function Base.convert(::Type{Interval}, interval::AnchoredInterval{P,T,L,R}) where {P,T,L,R}
    return Interval{T,L,R}(first(interval), last(interval))
end

function Base.convert(::Type{Interval{T}}, interval::AnchoredInterval{P,T,L,R}) where {P,T,L,R}
    return Interval{T,L,R}(first(interval), last(interval))
end

# Conversion methods which currently aren't needed but could prove useful. Commented out
# since these are untested.

#=
function Base.convert(::Type{AnchoredInterval{P,T}}, interval::Interval{T}) where {P,T}
    @assert abs(P) == span(interval)
    anchor = P < zero(P) ? last(interval) : first(interval)
    AnchoredInterval{P,T}(last(interval), inclusivity(interval))
end

function Base.convert(::Type{AnchoredInterval{P}}, interval::Interval{T}) where {P,T}
    @assert abs(P) == span(interval)
    anchor = P < zero(P) ? last(interval) : first(interval)
    AnchoredInterval{P,T}(anchor, inclusivity(interval))
end
=#

function Base.convert(::Type{AnchoredInterval{Ending}}, interval::Interval{T,L,R}) where {T,L,R}
    if !isbounded(interval)
        throw(ArgumentError("Unable to represent a non-bounded interval using a `AnchoredInterval`"))
    end
    AnchoredInterval{-span(interval), T, L, R}(last(interval))
end

function Base.convert(::Type{AnchoredInterval{Beginning}}, interval::Interval{T,L,R}) where {T,L,R}
    if !isbounded(interval)
        throw(ArgumentError("Unable to represent a non-bounded interval using a `AnchoredInterval`"))
    end
    AnchoredInterval{span(interval), T, L, R}(first(interval))
end

##### DISPLAY #####

function Base.show(io::IO, interval::T) where T <: AnchoredInterval
    if get(io, :compact, false)
        print(io, interval)
    else
        print(io, "$T(")
        show(io, anchor(interval))
        print(io, ")")
    end
end

function Base.print(io::IO, interval::AnchoredInterval{P,T}) where {P, T <: Union{Date, AbstractDateTime}}
    # Print to io in order to keep properties like :limit and :compact
    if get(io, :compact, false)
        io = IOContext(io, :limit=>true)
    end

    print(io, description(interval))
end

##### ARITHMETIC #####

Base.:+(a::T, b) where {T <: AnchoredInterval} = T(anchor(a) + b)

Base.:+(a, b::AnchoredInterval) = b + a
Base.:-(a::AnchoredInterval, b) = a + -b

# Required for StepRange{<:AnchoredInterval}
Base.:-(a::AnchoredInterval, b::AnchoredInterval) = anchor(a) - anchor(b)

Base.:-(a::T, b::AnchoredInterval{P,T}) where {P, T <: Number} = a + -b

function Base.:-(a::AnchoredInterval{P,T,L,R}) where {P, T <: Number, L, R}
    return AnchoredInterval{-P, T, R, L}(-anchor(a))
end

##### EQUALITY #####

function Base.:(==)(a::AnchoredInterval{P,T}, b::AnchoredInterval{P,T}) where {P,T}
    return anchor(a) == anchor(b) && bounds_types(a) == bounds_types(b)
end

# Required for min/max of AnchoredInterval{LaxZonedDateTime} when the anchor is AMB or DNE
function Base.isless(a::AnchoredInterval{P,T,L1}, b::AnchoredInterval{P,T,L2}) where {P,T,L1,L2}
    return (
        anchor(a) < anchor(b) ||
        (anchor(a) == anchor(b) && L1 === Closed && L2 === Open)
    )
end

##### RANGE #####

function Base.:(:)(start::T, step::S, stop::T) where {T <: AnchoredInterval, S}
    return StepRange{T,S}(start, step, stop)
end

function Base.:(:)(start::AnchoredInterval{P,T}, step::S, stop::AnchoredInterval{P,T}) where {P,T,S}
    return StepRange{AnchoredInterval{P,T}, S}(start, step, stop)
end

# Infer step for two-argument StepRange{<:AnchoredInterval}
function Base.:(:)(start::AnchoredInterval{P,T}, stop::AnchoredInterval{P,T}) where {P,T}
    return (:)(start, abs(P), stop)
end

function Base.steprange_last(start::T, step, stop::AnchoredInterval) where T <: AnchoredInterval
    T(Base.steprange_last(anchor(start), step, anchor(stop)))
end

function Base.length(r::StepRange{<:AnchoredInterval})
    return length(anchor(r.start):r.step:anchor(r.stop))
end

##### SET OPERATIONS #####

function Base.isempty(interval::AnchoredInterval{P,T}) where {P,T}
    return P == zero(P) && !isclosed(interval)
end

# When intersecting two `AnchoredInterval`s attempt to return an `AnchoredInterval`
function Base.intersect(a::AnchoredInterval{P,T}, b::AnchoredInterval{Q,T}) where {P,Q,T}
    interval = invoke(intersect, Tuple{AbstractInterval{T}, AbstractInterval{T}}, a, b)

    sp = isa(P, Period) ? canonicalize(typeof(P), span(interval)) : span(interval)
    if P ≤ zero(P)
        anchor = last(interval)
        new_P = -sp
    else
        anchor = first(interval)
        new_P = sp
    end

    L, R = bounds_types(interval)
    return AnchoredInterval{new_P, T, L, R}(anchor)
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

##### TIME ZONES #####

function TimeZones.astimezone(i::AnchoredInterval{P, ZonedDateTime, L, R}, tz::TimeZone) where {P,L,R}
    return AnchoredInterval{P, ZonedDateTime, L, R}(astimezone(anchor(i), tz))
end

TimeZones.timezone(i::AnchoredInterval{P, ZonedDateTime}) where P = timezone(anchor(i))
