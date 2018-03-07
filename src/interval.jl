"""
    Interval(first, last, [inclusivity::Inclusivity]) -> Interval
    Interval(first, last, [closed_left::Bool, closed_right::Bool]) -> Interval

An `Interval` represents a non-iterable range or span of values (non-interable because,
unlike a `StepRange`, no step is defined).

An `Interval` can be closed (both `first` and `last` are included in the interval), open
(neither `first` nor `last` are included), or half-open. This openness is defined by an
`Inclusivity` value, which defaults to closed.

### Example

```julia
julia> i = Interval(0, 100, true, false)
Interval{Int64}(0, 100, Inclusivity(true, false))

julia> in(0, i)
true

julia> in(50, i)
true

julia> in(100, i)
false

julia> intersect(Interval(0, 25, false, false), Interval(20, 50, true, true)
Interval{Int64}(20, 25, Inclusivity(true, false))
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
julia> i = Interval(Date(2016, 8, 11), Date(2013, 2, 13), false, true)
Interval{Date}(2013-02-13, 2016-08-11, Inclusivity(true, false))
```

Note that the `Inclusivity` value is also reversed in this case.

See also: [`AnchoredInterval`](@ref), [`Inclusivity`](@ref)
"""
struct Interval{T} <: AbstractInterval{T}
    first::T
    last::T
    inclusivity::Inclusivity

    function Interval{T}(f::T, l::T, inc::Inclusivity) where T
        return new(
            f ≤ l ? f : l,
            l ≥ f ? l : f,
            f ≤ l ? inc : Inclusivity(last(inc), first(inc)),
        )
    end
end

Interval(f::T, l::T, inclusivity) where T = Interval{T}(f, l, inclusivity)
Interval{T}(f, l, x::Bool, y::Bool) where T = Interval{T}(f, l, Inclusivity(x, y))
Interval(f, l, x::Bool, y::Bool) = Interval(f, l, Inclusivity(x, y))
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
isclosed(interval::AbstractInterval) = isclosed(inclusivity(interval))
Base.isopen(interval::AbstractInterval) = isopen(inclusivity(interval))

##### CONVERSION #####

function Base.convert(::Type{T}, i::Interval{T}) where T
    first(i) == last(i) && isclosed(i) && return first(i)
    throw(DomainError())
end

# Date/DateTime attempt to convert to Int64 instead of falling back to convert(T, ...)
Base.Date(interval::Interval{Date}) = convert(Date, interval)
Base.DateTime(interval::Interval{DateTime}) = convert(DateTime, interval)

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

function Base.print(io::IO, interval::AbstractInterval)
    # Print to io in order to keep properties like :limit and :compact
    if get(io, :compact, false)
        io = IOContext(io, :limit=>true)
    end

    print(
        io,
        first(inclusivity(interval)) ? "[" : "(",
        first(interval),
        "..",
        last(interval),
        last(inclusivity(interval)) ? "]" : ")",
    )
end

##### ARITHMETIC #####

function Base.:+(a::Interval{T}, b::T) where T
    return Interval{T}(first(a) + b, last(a) + b, inclusivity(a))
end

function Base.:+(a::Interval{Char}, b::Integer)
    return Interval{Char}(first(a) + b, last(a) + b, inclusivity(a))
end

function Base.:+(a::Interval{T}, b::Period) where T <: TimeType
    return Interval{T}(first(a) + b, last(a) + b, inclusivity(a))
end

Base.:+(a::T, b::Interval{T}) where T = b + a
Base.:+(a::Integer, b::Interval{Char}) = b + a
Base.:+(a::Period, b::Interval{T}) where T <: TimeType = b + a

Base.:-(a::Interval{T}, b::T) where T = a + -b
Base.:-(a::Interval{Char}, b::Integer) = a + -b
Base.:-(a::Interval{T}, b::Period) where T <: TimeType = a + -b

Base.:-(a::T, b::Interval{T}) where T = a + -b

function Base.:-(a::Interval{T}) where T
    inc = inclusivity(a)
    Interval{T}(-last(a), -first(a), Inclusivity(last(inc), first(inc)))
end

##### EQUALITY #####

function Base.isless(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    return RightEndpoint(a) < LeftEndpoint(b)
end

Base.isless(a::AbstractInterval{T}, b::T) where T = RightEndpoint(a) < b
Base.isless(a::T, b::AbstractInterval{T}) where T = a < LeftEndpoint(b)

##### SET OPERATIONS #####

function Base.isempty(i::Interval)
    return first(i) == last(i) && inclusivity(i) != Inclusivity(true, true)
end

Base.in(a::T, b::AbstractInterval{T}) where T = !(a > b || a < b)

function Base.in(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    return LeftEndpoint(a) >= LeftEndpoint(b) && RightEndpoint(a) <= RightEndpoint(b)
end

# Should probably define union, too. There is power in a union.

function Base.intersect(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    left = max(LeftEndpoint(a), LeftEndpoint(b))
    right = min(RightEndpoint(a), RightEndpoint(b))
    left > right && return Interval{T}()
    return Interval{T}(left.endpoint, right.endpoint, left.included, right.included)
end
