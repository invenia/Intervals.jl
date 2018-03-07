using Base.Dates: value, coarserperiod

"""
    AnchoredInterval{T, S, E}(anchor::T, [span::S, inclusivity::Inclusivity])
    AnchoredInterval{T, S, E}(anchor::T, [span::S, closed_left::Bool, closed_right::Bool])

    AnchoredInterval{T, S, E}(anchor::T, [inclusivity::Inclusivity])
    AnchoredInterval{T, S, E}(anchor::T, [closed_left::Bool, closed_right::Bool])

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

To this end, `HourEnding` is a type alias for `AnchoredInterval{T, Hour, Ending} where T`.
Similarly, `HourBeginning` is a type alias for
`AnchoredInterval{T, Hour, Beginning} where T`.

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
julia> AnchoredInterval(DateTime(2016, 8, 11, 12), Hour(-1))
HourEnding{DateTime}(2016-08-11T12:00:00, -1 hour, Inclusivity(false, true))

julia> AnchoredInterval(DateTime(2016, 8, 11), Day(1))
AnchoredInterval{DateTime, Day, Beginning}(2016-08-11T00:00:00, 1 day, Inclusivity(true, false))

julia> AnchoredInterval(DateTime(2016, 8, 11, 12, 30), Minute(5), true, true)
AnchoredInterval{DateTime, Minute, Beginning}(2016-08-11T12:30:00, 5 minutes, Inclusivity(true, true))
```

See also: [`Interval`](@ref), [`Inclusivity`](@ref), [`HE`](@ref), [`HB`](@ref)
"""
struct AnchoredInterval{T, S, E} <: AbstractInterval{T}
    anchor::T
    span::S
    inclusivity::Inclusivity

    function AnchoredInterval{T, S, E}(anchor::T, span::S, inc::Inclusivity) where {T, S, E}
        @assert E isa Direction
        if span < zero(S)
            @assert E == Ending
        elseif span > zero(S)
            @assert E == Beginning
        else
            @assert E isa Direction
        end
        @assert typeof(anchor + span) == T
        new{T, S, E}(anchor, span, inc)
    end
end

function AnchoredInterval{T, S, E}(anchor::T, span::S, x::Bool, y::Bool) where {T, S, E}
    AnchoredInterval{T, S, E}(anchor, span, Inclusivity(x, y))
end
function AnchoredInterval{T, S, E}(anchor::T, span::S) where {T, S, E}
    # If an interval is anchored to the lesser endpoint, default to Inclusivity(false, true)
    # If an interval is anchored to the greater endpoint, default to Inclusivity(true, false)
    AnchoredInterval{T, S, E}(anchor, span, Inclusivity(span ≥ zero(S), span ≤ zero(S)))
end
function AnchoredInterval{T, S, E}(anchor::T, inc::Inclusivity) where {T, S, E}
    span = E == Ending ? -oneunit(S) : oneunit(S)
    AnchoredInterval{T, S, E}(anchor, span, inc)
end
function AnchoredInterval{T, S, E}(anchor::T, x::Bool, y::Bool) where {T, S, E}
    AnchoredInterval{T, S, E}(anchor, Inclusivity(x, y))
end
function AnchoredInterval{T, S, E}(anchor::T) where {T, S, E}
    span = E == Ending ? -oneunit(S) : oneunit(S)
    AnchoredInterval{T, S, E}(anchor, span)
end

function AnchoredInterval{T, S}(anchor::T, span::S, args...) where {T, S}
    E = if span < zero(S)
        Ending
    elseif span > zero(S)
        Beginning
    else
        throw(ArgumentError("Must specify endpoint type when span is zero"))
    end
    AnchoredInterval{T, S, E}(anchor, span, args...)
end

function AnchoredInterval{T}(anchor::T, span::S, args...) where {T, S}
    AnchoredInterval{T, S}(anchor, span, args...)
end

function AnchoredInterval(anchor::T, span::S, args...) where {T, S}
    AnchoredInterval{T, S}(anchor, span, args...)
end


const HourEnding{T} = AnchoredInterval{T, Hour, Ending} where T <: TimeType
HourEnding(a::T, args...) where T = HourEnding{T}(a, args...)

const HourBeginning{T} = AnchoredInterval{T, Hour, Beginning} where T <: TimeType
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

function Base.copy(x::AnchoredInterval{T, S, E}) where {T, S, E}
    return AnchoredInterval{T, S, E}(anchor(x), inclusivity(x))
end

##### ACCESSORS #####

function Base.first(interval::AnchoredInterval)
    min(interval.anchor, interval.anchor + interval.span)
end

function Base.last(interval::AnchoredInterval)
    max(interval.anchor, interval.anchor + interval.span)
end

anchor(interval::AnchoredInterval) = interval.anchor
span(interval::AnchoredInterval) = abs(interval.span)

##### CONVERSION #####

function Base.convert(::Type{Interval}, interval::AnchoredInterval{T}) where T
    return Interval{T}(first(interval), last(interval), inclusivity(interval))
end

function Base.convert(::Type{Interval{T}}, interval::AnchoredInterval{T}) where T
    return Interval{T}(first(interval), last(interval), inclusivity(interval))
end

# Conversion methods which currently aren't needed but could prove useful. Commented out
# since these are untested.

#=
function Base.convert(::Type{AnchoredInterval{Ending}}, interval::Interval{T}) where T
    AnchoredInterval{T}(last(interval), -span(interval), inclusivity(interval))
end

function Base.convert(::Type{AnchoredInterval{Beginning}}, interval::Interval{T}) where T
    AnchoredInterval{T}(first(interval), span(interval), inclusivity(interval))
end
=#

Base.convert(::Type{T}, interval::AnchoredInterval{T}) where T = anchor(interval)

# Date/DateTime attempt to convert to Int64 instead of falling back to convert(T, ...)
Base.Date(interval::AnchoredInterval{Date}) = convert(Date, interval)
Base.DateTime(interval::AnchoredInterval{DateTime}) = convert(DateTime, interval)

##### DISPLAY #####

Base.show(io::IO, ::Type{HourEnding}) = print(io, "HourEnding{T}")
Base.show(io::IO, ::Type{HourBeginning}) = print(io, "HourBeginning{T}")

Base.show(io::IO, ::Type{HourEnding{T}}) where T <: TimeType = print(io, "HourEnding{$T}")
Base.show(io::IO, ::Type{HourBeginning{T}}) where T <: TimeType = print(io, "HourBeginning{$T}")

function Base.show(io::IO, ::Type{AnchoredInterval{T, S, E}}) where {T, S, E}
    d = E == Beginning ? "Beginning" : "Ending"
    print(io, "AnchoredInterval{$T, $S, $d}")
end

function Base.show(io::IO, interval::AnchoredInterval)
    if get(io, :compact, false)
        print(io, interval)
    else
        show(io, typeof(interval))
        print(io, "(")
        show(io, anchor(interval))
        print(io, ", ")
        show(io, interval.span)
        print(io, ", ")
        show(io, inclusivity(interval))
        print(io, ")")
    end
end

function Base.print(io::IO, interval::AnchoredInterval{<:TimeType})
    # Print to io in order to keep properties like :limit and :compact
    if get(io, :compact, false)
        io = IOContext(io, :limit=>true)
    end

    print(io, description(interval))
end

##### ARITHMETIC #####

Base.:+(a::T, b) where {T <: AnchoredInterval} = T(anchor(a) + b, a.span, inclusivity(a))

Base.:+(a, b::AnchoredInterval) = b + a
Base.:-(a::AnchoredInterval, b) = a + -b

# Required for StepRange{<:AnchoredInterval}
Base.:-(a::AnchoredInterval, b::AnchoredInterval) = anchor(a) - anchor(b)

Base.:-(a::T, b::AnchoredInterval{T}) where {T <: Number} = a + -b

function Base.:-(a::AnchoredInterval{T, S, Ending}) where {T <: Number, S}
    inc = inclusivity(a)
    AnchoredInterval{T, S, Beginning}(-anchor(a), -a.span, Inclusivity(last(inc), first(inc)))
end

function Base.:-(a::AnchoredInterval{T, S, Beginning}) where {T <: Number, S}
    inc = inclusivity(a)
    AnchoredInterval{T, S, Ending}(-anchor(a), -a.span, Inclusivity(last(inc), first(inc)))
end

##### EQUALITY #####

# Required for min/max of AnchoredInterval{LaxZonedDateTime} when the anchor is AMB or DNE
function Base.:<(a::AnchoredInterval{T, S, E}, b::AnchoredInterval{T, S, E}) where {T, S, E}
    return anchor(a) < anchor(b)
end

##### RANGE #####

# Required for StepRange{<:AnchoredInterval}
function Base.steprem(a::T, b::T, c) where {T <: AnchoredInterval}
    return Base.steprem(anchor(a), anchor(b), c)
end

# Infer step for two-argument StepRange{<:AnchoredInterval}
function Base.colon(start::AnchoredInterval{T, S}, stop::AnchoredInterval{T, S}) where {T,S}
    return colon(start, oneunit(S), stop)
end

function Base.length(r::StepRange{<:AnchoredInterval})
    return length(anchor(r.start):r.step:anchor(r.stop))
end

##### SET OPERATIONS #####

function Base.isempty(interval::AnchoredInterval{T, S}) where {T, S}
    return span(interval) == zero(S) && !isclosed(interval)
end

function Base.intersect(a::AnchoredInterval{T, S, E}, b::AnchoredInterval{T, S, E}) where {T, S, E}
    interval = invoke(intersect, Tuple{AbstractInterval{T}, AbstractInterval{T}}, a, b)

    sp = S <: Period ? canonicalize(S, span(interval)) : span(interval)
    if E == Ending
        anchor = last(interval)
        sp = -sp
    else
        anchor = first(interval)
        sp = sp
    end

    return AnchoredInterval{T, S, E}(anchor, sp, inclusivity(interval))
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
