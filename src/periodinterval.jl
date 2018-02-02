abstract type PeriodInterval{P, T} <: AbstractInterval end

"""
    PeriodEnding{P, T}(instant::T, [inclusivity::Inclusivity]) where {P, T <: TimeType} -> PeriodEnding{P, T}

`PeriodEnding` is a subtype of `AbstractInterval` that represents a span of time
(defined by the value parameter `P`) that ends at a specific time (`instant::T`).

The interval represented by a `PeriodEnding` value may be closed (both the start and
endpoint are included in the interval), open (neither the start nor the endpoint are
included), or partially open. This openness is defined by `inclusivity`, which defaults to
partially open (with the endpoint included and the start excluded).

Where you would use `PeriodEnding{Hour(1)}(x)`, you may use `HourEnding(x)` typealias
instead.

### Rounding

The `instant` provided is rounded up to the nearest `duration` using `ceil`. This means that
`PeriodEnding{Hour(1)}(DateTime(2016, 8, 11, 12, 30))` is equivalent to
`PeriodEnding{Hour(1)}(DateTime(2016, 8, 11, 13))`.

### Example

```julia
julia> PeriodEnding{Minute(5)}(DateTime(2016, 8, 11, 12, 30, 5))
PeriodEnding{5 minutes, DateTime}(2016-08-11T12:35:00, Inclusivity(false, true))

julia> PeriodEnding{Hour(1)}(DateTime(2016, 8, 11, 12))
PeriodEnding{1 hour, DateTime}(2016-08-11T12:00:00, Inclusivity(false, true))

julia> PeriodEnding{Day(1)}(Date(2016, 8, 11), Inclusivity(true, false))
PeriodEnding{1 day, Date}(2016-08-11, Inclusivity(true, false))
```

See also: [`PeriodBeginning`](@ref), [`Interval`](@ref), [`Inclusivity`](@ref)
"""
struct PeriodEnding{P, T <: TimeType} <: PeriodInterval{P, T}
#@auto_hash_equals struct PeriodEnding{T<:TimeType, P} <: PeriodInterval
    instant::T
    inclusivity::Inclusivity

    function PeriodEnding{P, T}(instant::T, inc::Inclusivity) where {P, T <: TimeType}
        return new(ceil(instant, P::Period), inc)
    end
end

PeriodEnding{P, T}(i::T) where {P, T} = PeriodEnding{P, T}(i::T, Inclusivity(false, true))
PeriodEnding{P}(i::T, inclusivity) where {P, T} = PeriodEnding{P, T}(i, inclusivity)
PeriodEnding{P}(i::T) where {P, T} = PeriodEnding{P, T}(i)

const HourEnding{T <: TimeType} = PeriodEnding{Dates.Hour(1), T}
HourEnding(i::T, inclusivity) where T = HourEnding{T}(i, inclusivity)
HourEnding(i::T) where T = HourEnding{T}(i)

# TODO do you really need autohashequals? probably not
# TODO 100% test coverage
# TODO add `in` tests with DST
# TODO check equality, hashing, etc.
# TODO add tests for hash equality for PeriodEnding, PeriodBeginning, Inclusivity, Interval
# TODO test isless
# TODO generalize PeriodEnding and PeriodBeginning to IntervalEnding and IntervalBeginning?

"""
    PeriodBeginning{P, T}(instant::T, [inclusivity::Inclusivity]) where {P, T <: TimeType} -> PeriodBeginning{P, T}

`PeriodBeginning` is a subtype of `AbstractInterval` that represents a span of time
(defined by the value parameter `P`) that begins at a specific time (`instant::T`).

The interval represented by a `PeriodBeginning` value may be closed (both the start and
endpoint are included in the interval), open (neither the start nor the endpoint are
included), or partially open. This openness is defined by `inclusivity`, which defaults to
partially open (with the start included and the endpoint excluded).

Where you would use `PeriodBeginning{Hour(1)}(x)`, you may use `HourBeginning(x)` typealias
instead.

### Rounding

The `instant` provided is rounded down to the nearest `duration` using `floor`. This means
that `PeriodBeginning{Hour(1)}(DateTime(2016, 8, 11, 12, 30))` is equivalent to
`PeriodBeginning{Hour(1)}(DateTime(2016, 8, 11, 12))`.

### Example

```julia
julia> PeriodBeginning{Minute(5)}(DateTime(2016, 8, 11, 12, 30, 5))
PeriodBeginning{5 minutes, DateTime}(2016-08-11T12:30:00, Inclusivity(true, false))

julia> PeriodBeginning{Hour(1)}(DateTime(2016, 8, 11, 12))
PeriodBeginning{1 hour, DateTime}(2016-08-11T12:00:00, Inclusivity(true, false))

julia> PeriodBeginning{Day(1)}(Date(2016, 8, 11), Inclusivity(false, true))
PeriodBeginning{1 day, Date}(2016-08-11, Inclusivity(false, true))
```

See also: [`PeriodEnding`](@ref), [`Interval`](@ref), [`Inclusivity`](@ref)
"""
struct PeriodBeginning{P, T<:TimeType} <: PeriodInterval{P, T}
#@auto_hash_equals struct PeriodBeginning{T<:TimeType, P} <: PeriodInterval
    instant::T
    inclusivity::Inclusivity

    function PeriodBeginning{P, T}(instant::T, inc::Inclusivity) where {P, T <: TimeType}
        return new(floor(instant, P::Period), inc)
    end
end

PeriodBeginning{P, T}(i::T) where {P, T} = PeriodBeginning{P, T}(i, Inclusivity(true,false))
PeriodBeginning{P}(i::T, inclusivity) where {P, T} = PeriodBeginning{P, T}(i, inclusivity)
PeriodBeginning{P}(i::T) where {P, T} = PeriodBeginning{P, T}(i)

const HourBeginning{T} = PeriodBeginning{Dates.Hour(1), T} where T <: TimeType
#HourBeginning{T}(i) where T = HourBeginning{T}(i, Inclusivity(false, true))
HourBeginning(i::T, inclusivity) where T = HourBeginning{T}(i, inclusivity)
HourBeginning(i::T) where T = HourBeginning{T}(i)

##### CONVERSION #####

function Base.convert(::Type{Interval{T}}, interval::PeriodEnding{P, T}) where {P, T}
    return Interval{T}(interval.instant - P, interval.instant, interval.inclusivity)
end

function Base.convert(::Type{Interval{T}}, interval::PeriodBeginning{P, T}) where {P, T}
    return Interval{T}(interval.instant, interval.instant + P, interval.inclusivity)
end

##### DISPLAY #####

function Base.show(io::IO, interval::PeriodEnding{P, T}) where {P, T}
    if get(io, :compact, false)
        print(io, interval)
    else
        print(io, "PeriodEnding{$P, $T}($(interval.instant), ")
        show(io, interval.inclusivity)
        print(io, ")")
    end
end

function Base.show(io::IO, interval::PeriodBeginning{P, T}) where {P, T}
    if get(io, :compact, false)
        print(io, interval)
    else
        print(io, "PeriodBeginning{$P, $T}($(interval.instant), ")
        show(io, interval.inclusivity)
        print(io, ")")
    end
end

function Base.print(io::IO, interval::PeriodInterval)
    # Print to io in order to keep properties like :limit and :compact

    if get(io, :compact, false)
        io = IOContext(io, :limit=>true)
    end

    print(io, summary(interval))
end

##### ARITHMETIC #####

function Base.:+(interval::PeriodEnding{P, T}, p::Period) where {P, T}
    return PeriodEnding{P, T}(interval.instant + p, interval.inclusivity)
end

function Base.:+(interval::PeriodBeginning{P, T}, p::Period) where {P, T}
    return PeriodEnding{P, T}(interval.instant + p, interval.inclusivity)
end

Base.:+(period::Period, interval::PeriodInterval) = interval + period
Base.:-(interval::PeriodInterval, period::Period) = interval + -period

# Required for StepRange{<:PeriodInterval}
Base.:-(a::I, b::I) where {P, T, I <: PeriodInterval{P, T}} = a.instant - b.instant

# Required for StepRange{<:PeriodInterval}
function Base.steprem(a::I, b::I, c) where {P, T, I <: PeriodInterval{P, T}}
    return Base.steprem(a.instant,b.instant,c)
end

# Infer step for two-argument StepRange{<:PeriodInterval}
function Base.colon(start::I, stop::I) where {P, T, I <: PeriodInterval{P, T}}
    return colon(start, P, stop)
end

##### EQUALITY #####

function Base.isless(a::PeriodInterval{P, T}, b::PeriodInterval{Q, U}) where {P, Q, T, U}
    isless(Interval{T}(a), Interval{U}(b))
end

##### SET OPERATIONS #####

function Base.isempty(interval::I) where {P, T, I <: PeriodInterval{P, T}}
    return Base.Dates.value(P) == 0 && interval.inclusivity != Inclusivity(true, true)
end

function Base.in(x::T, interval::I) where {P, T, I <: PeriodInterval{P, T}}
    return in(x, Interval{T}(interval))
end
