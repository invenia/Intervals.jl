"""
    Interval(first, last, [inclusivity::Inclusivity]) -> Interval

An `Interval` represents a non-iterable range or span of values (non-interable because,
unlike a `StepRange`, there is no step).

`Interval`s can be closed (both `first` and `last` are included in the span), closed
(neither `first` nor `last` are included in the span), or partially open. An `Interval`'s
openness is defined by an `Inclusivity` value.

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

A closed `Interval` can be constructed with the `..` infix constructor:

```julia
julia> Dates.today() - Dates.Week(1) .. Dates.today()
Interval{Date}(2018-01-24, 2018-01-31, Inclusivity(true, true))
```

### Note on Ordering

The `Interval` constructor will compare `first` and `last`; if it findes that
`first > last`, they will be reversed to ensure that `first < last`. This simplifies
calls to `in` and `intersect`:

```julia
julia> i = Interval(Date(2016, 8, 11), Date(2013, 2, 13), Inclusivity(false, true))
Interval{Date}(2013-02-13, 2016-08-11, Inclusivity(true, false))
```

Note that the `Inclusivity` value is also reversed in this case.

See also: [`PeriodBeginning`](@ref), [`PeriodEnding`](@ref), [`Inclusivity`](@ref)
"""
struct Interval{T} <: AbstractInterval{T}
    first::T
    last::T
    inclusivity::Inclusivity

    function Interval{T}(f::T, l::T, inc::Inclusivity) where T
        return new(
            f <= l ? f : l,
            l >= f ? l : f,
            f <= l ? inc : Inclusivity(last(inc), first(inc)),
        )
    end
end

Interval(f::T, l::T, inclusivity) where T = Interval{T}(f, l, inclusivity)
Interval(f::T, l::T) where T = Interval(f, l, Inclusivity(true, true))
(..)(f::T, l::T) where T = Interval(f, l)

# Empty Intervals
Interval{T}() where T = Interval{T}(zero(T), zero(T), Inclusivity(false, false))
Interval{T}() where T <: TimeType = Interval{T}(T(0), T(0), Inclusivity(false, false))

function Interval{T}() where T <: ZonedDateTime
    return Interval{T}(T(0, tz"UTC"), T(0, tz"UTC"), Inclusivity(false, false))
end

Base.copy(x::Interval{T}) where T = Interval{T}(x.first, x.last, x.inclusivity)

##### ACCESSORS #####

Base.first(interval::Interval) = interval.first
Base.last(interval::Interval) = interval.last
span(interval::Interval) = interval.last - interval.first
inclusivity(interval::AbstractInterval) = interval.inclusivity

##### DISPLAY #####

function Base.show(io::IO, interval::Interval{T}) where T
    if get(io, :compact, false)
        print(io, interval)
    else
        print(io, "Interval{$T}(")
        show(io, interval.first)
        print(io, ", ")
        show(io, interval.last)
        print(io, ", ")
        show(io, interval.inclusivity)
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
        interval.inclusivity.first ? "[" : "(",
        interval.first,
        "..",
        interval.last,
        interval.inclusivity.last ? "]" : ")",
    )
end

##### ARITHMETIC #####

function Base.:+(a::Interval{T}, b::T) where T
    return Interval{T}(a.first + b, a.last + b, a.inclusivity)
end

function Base.:+(a::Interval{Char}, b::Integer)
    return Interval{Char}(a.first + b, a.last + b, a.inclusivity)
end

function Base.:+(a::Interval{T}, b::Period) where T <: TimeType
    return Interval{T}(a.first + b, a.last + b, a.inclusivity)
end

Base.:+(a::T, b::Interval{T}) where T = b + a
Base.:+(a::Integer, b::Interval{Char}) = b + a
Base.:+(a::Period, b::Interval{T}) where T <: TimeType = b + a

Base.:-(a::Interval{T}, b::T) where T = a + -b
Base.:-(a::Interval{Char}, b::Integer) = a + -b
Base.:-(a::Interval{T}, b::Period) where T <: TimeType = a + -b

##### EQUALITY #####

Base.isless(a::Interval, b::Interval) = isempty(intersect(a, b)) && isless(a.first, b.first)

##### SET OPERATIONS #####

function Base.isempty(i::Interval)
    return (
        i.first > i.last ||   # Shouldn't be possible, but check anyway.
        (i.first == i.last && i.inclusivity != Inclusivity(true, true))
    )
end

function Base.in(x::T, interval::AbstractInterval{T}) where T
    check_first = inclusivity(interval).first ? (>=) : (>)
    check_last = inclusivity(interval).last ? (<=) : (<)
    return check_first(x, first(interval)) && check_last(x, last(interval))
end

# TODO: Should probably define union, too. There is power in a union.

function Base.intersect(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    firstpoint = first(a) > first(b) ? first(a) : first(b)
    endpoint = last(a) < last(b) ? last(a) : last(b)

    # If first > last, there's no intersection, so we explicitly return an empty interval.
    # We can't just return Interval(first, last, inclusivity) because the constructor
    # would rearrange first and last in this case to make a non-empty interval.
    firstpoint > endpoint && return Interval{T}()

    # These two consecutive ifs could be cleaned up with a fancy loop (but don't forget to
    # change > to < when comparing a.last to b.last!
    if inclusivity(a).first == inclusivity(b).first
        # If a and b have the same inclusivity, the inclusivity of the intersection is easy.
        i_first = inclusivity(a).first
    else
        if first(a) == first(b)
            i_first = false
        elseif first(a) > first(b)
            i_first = inclusivity(a).first
        else
            i_first = inclusivity(b).first
        end
    end

    if inclusivity(a).last == inclusivity(b).last
        # If a and b have the same inclusivity, the inclusivity of the intersection is easy.
        i_last = inclusivity(a).last
    else
        if last(a) == last(b)
            i_last = false
        elseif last(a) < last(b)
            i_last = inclusivity(a).last
        else
            i_last = inclusivity(b).last
        end
    end

    return Interval{T}(firstpoint, endpoint, Inclusivity(i_first, i_last))
end
