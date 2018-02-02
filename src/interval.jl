"""
    Interval(start, finish, [inclusivity::Inclusivity]) -> Interval

An `Interval` represents a non-iterable range or span of values (non-interable because,
unlike a `StepRange`, there is no step).

`Interval`s can be closed (both the start and endpoint are included in the span),
closed (neither the start nor the endpoint are included in the span), or partially open. An
`Interval`'s openness is defined by an `Inclusivity` value.

If no `Inclusivity` is provided, the `Interval` defaults to closed.

### Example

```julia
julia> i = Interval(0, 100, Inclusivity(true, false))
Interval{Int64}(0, 100, Inclusivity(true, false))

julia> in(0, i)
true

julia> in(50, i)
true

julia> in(100, i)
false
```

### Infix Constructor: `..`

A closed interveral can be constructed with the `..` infix constructor:

```julia
julia> Dates.today() - Dates.Week(1) .. Dates.today()
Interval{Date}(2018-01-24, 2018-01-31, Inclusivity(true, true))
```

### Note on Ordering

The `Interval` constructor will compare `start` and `finish`; if it findes that
`start > finish`, they will be reversed to ensure that `start < finish`. This simplifies
calls to `in` and `intersect`:

```julia
julia> i = Interval(Date(2016, 8, 11), Date(2013, 2, 13), Inclusivity(false, true))
Interval{Date}(2013-02-13, 2016-08-11, Inclusivity(true, false))
```

Note that the `Inclusivity` value is also reversed in this case.

See also: [`PeriodBeginning`](@ref), [`PeriodEnding`](@ref), [`Inclusivity`](@ref)
"""
struct Interval{T} <: AbstractInterval
#@auto_hash_equals struct Interval{T} <: AbstractInterval
    start::T
    finish::T
    inclusivity::Inclusivity

    function Interval{T}(start::T, finish::T, inc::Inclusivity) where T
        return new(
            start <= finish ? start : finish,
            finish >= start ? finish : start,
            start <= finish ? inc : Inclusivity(inc.finish, inc.start),
        )
    end
end

Interval(start::T, finish::T, inclusivity) where T = Interval{T}(start, finish, inclusivity)
Interval(start::T, finish::T) where T = Interval(start, finish, Inclusivity(true, true))
(..)(start::T, finish::T) where T = Interval(start, finish)

# Empty Intervals
Interval{T}() where T = Interval{T}(zero(T), zero(T), Inclusivity(false, false))
Interval{T}() where T <: TimeType = Interval{T}(T(0), T(0), Inclusivity(false, false))

function Interval{T}() where T <: ZonedDateTime
    return Interval{T}(T(0, tz"UTC"), T(0, tz"UTC"), Inclusivity(false, false))
end

##### DISPLAY #####

function Base.show(io::IO, interval::Interval{T}) where T
    if get(io, :compact, false)
        print(io, interval)
    else
        print(io, "Interval{$T}(", interval.start, ", ", interval.finish, ", ")
        show(io, interval.inclusivity)  # Display inclusivity in Julia (not human) format
        print(io, ")")
    end
end

function Base.print(io::IO, interval::Interval)
    # Print to io in order to keep properties like :limit and :compact

    if get(io, :compact, false)
        io = IOContext(io, :limit=>true)
    end

    print(
        io,
        interval.inclusivity.start ? "[" : "(",
        interval.start,
        "..",
        interval.finish,
        interval.inclusivity.finish ? "]" : ")",
    )
end

##### ARITHMETIC #####

function Base.:+(a::Interval{T}, b::T) where T
    return Interval{T}(a.start + b, a.finish + b, a.inclusivity)
end

function Base.:+(a::Interval{T}, b::Period) where T <: TimeType
    return Interval{T}(a.start + b, a.finish + b, a.inclusivity)
end

Base.:+(a::T, b::Interval{T}) where T = b + a
Base.:+(a::Period, b::Interval{T}) where T <: TimeType = b + a

Base.:-(a::Interval{T}, b::T) where T = a + -b
Base.:-(a::Interval{T}, b::Period) where T <: TimeType = a + -b

##### EQUALITY #####

# TODO add equality/hash tests
# TODO test isless

Base.isless(a::Interval, b::Interval) = isempty(intersect(a, b)) && isless(a.start, b.start)

##### SET OPERATIONS #####

function Base.isempty(i::Interval)
    return (
        i.start > i.finish ||   # Shouldn't be possible, but check anyway.
        (i.start == i.finish && i.inclusivity != Inclusivity(true, true))
    )
end

function Base.in(x::T, interval::Interval{T}) where T
    check_start = interval.inclusivity.start ? (>=) : (>)
    check_finish = interval.inclusivity.finish ? (<=) : (<)
    return check_start(x, interval.start) && check_finish(x, interval.finish)
end

function Base.intersect(a::Interval{T}, b::Interval{T}) where T
    start = a.start > b.start ? a.start : b.start
    finish = a.finish < b.finish ? a.finish : b.finish

    # If start > finish, there's no intersection, so we explicitly return an empty interval.
    # We can't just return Interval(start, finish, inclusivity) because the constructor
    # would rearrange start and finish in this case to make a non-empty interval.
    start > finish && return Interval{T}()

    # These two consecutive ifs could be cleaned up with a fancy loop (but don't forget to
    # change > to < when comparing a.finish to b.finish!
    if a.inclusivity.start == b.inclusivity.start
        # If a and b have the same inclusivity, the inclusivity of the intersection is easy.
        i_start = a.inclusivity.start
    else
        if a.start == b.start
            i_start = false
        elseif a.start > b.start
            i_start = a.inclusivity.start
        else
            i_start = b.inclusivity.start
        end
    end

    if a.inclusivity.finish == b.inclusivity.finish
        # If a and b have the same inclusivity, the inclusivity of the intersection is easy.
        i_finish = a.inclusivity.finish
    else
        if a.finish == b.finish
            i_finish = false
        elseif a.finish < b.finish
            i_finish = a.inclusivity.finish
        else
            i_finish = b.inclusivity.finish
        end
    end

    return Interval{T}(start, finish, Inclusivity(i_start, i_finish))
end

# TODO: Should probably define union, too. There is power in a union.
