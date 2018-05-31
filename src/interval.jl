import TimeZones: astimezone

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

function Base.merge(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    isempty(intersect(a, b)) && throw(ArgumentError("$a and $b do not intersect."))

    left = min(LeftEndpoint(a), LeftEndpoint(b))
    right = max(RightEndpoint(a), RightEndpoint(b))
    return Interval(
        left.endpoint,
        right.endpoint,
        Inclusivity(left.included, right.included)
    )
end

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
        " .. ",
        last(interval),
        last(inclusivity(interval)) ? "]" : ")",
    )
end

##### ARITHMETIC #####

Base.:+(a::T, b) where {T <: Interval} = T(first(a) + b, last(a) + b, inclusivity(a))

Base.:+(a, b::Interval) = b + a
Base.:-(a::Interval, b) = a + -b

Base.:-(a::T, b::Interval{T}) where T = a + -b

function Base.:-(a::Interval{T}) where T
    inc = inclusivity(a)
    Interval{T}(-last(a), -first(a), Inclusivity(last(inc), first(inc)))
end

##### EQUALITY #####

function Base.:(==)(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    return LeftEndpoint(a) == LeftEndpoint(b) && RightEndpoint(a) == RightEndpoint(b)
end

# While it might be convincingly argued that this should define < instead of isless (see
# https://github.com/invenia/Intervals.jl/issues/14), this breaks sort.
Base.isless(a::AbstractInterval{T}, b::T) where T = LeftEndpoint(a) < b
Base.isless(a::T, b::AbstractInterval{T}) where T = a < LeftEndpoint(b)

less_than_disjoint(a::AbstractInterval{T}, b::T) where T = RightEndpoint(a) < b
less_than_disjoint(a::T, b::AbstractInterval{T}) where T = a < LeftEndpoint(b)

function Base.:isless(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    return LeftEndpoint(a) < LeftEndpoint(b)
end

function less_than_disjoint(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    return RightEndpoint(a) < LeftEndpoint(b)
end

greater_than_disjoint(a, b) = less_than_disjoint(b, a)

"""
    ≪(a::AbstractInterval, b::AbstractInterval) -> Bool
    less_than_disjoint(a::AbstractInterval, b::AbstractInterval) -> Bool

Less-than-and-disjoint comparison operator. Returns `true` if `a` is less than `b` and they
are disjoint (they do not overlap).

```
julia> 0..10 ≪ 10..20
false

julia> 0..10 ≪ 11..20
true
```
"""
≪(a, b) = less_than_disjoint(a, b)
# ≪̸(a, b) = !≪(a, b)

"""
    ≫(a::AbstractInterval, b::AbstractInterval) -> Bool
    greater_than_disjoint(a::AbstractInterval, b::AbstractInterval) -> Bool

Greater-than-and-disjoint comparison operator. Returns `true` if `a` is greater than `b` and
they are disjoint (they do not overlap).

```
julia> 10..20 ≫ 0..10
false

julia> 11..20 ≫ 0..10
true
```
"""
≫(a, b) = greater_than_disjoint(a, b)
# ≫̸(a, b) = !≫(a, b)

##### SET OPERATIONS #####

Base.isempty(i::AbstractInterval) = LeftEndpoint(i) > RightEndpoint(i)
Base.in(a::T, b::AbstractInterval{T}) where T = !(a ≫ b || a ≪ b)

function Base.issubset(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    return LeftEndpoint(a) ≥ LeftEndpoint(b) && RightEndpoint(a) ≤ RightEndpoint(b)
end

Base.:⊈(a::AbstractInterval{T}, b::AbstractInterval{T}) where T = !issubset(a, b)
Base.:⊉(a::AbstractInterval{T}, b::AbstractInterval{T}) where T = !issubset(b, a)

function Base.intersect(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    left = max(LeftEndpoint(a), LeftEndpoint(b))
    right = min(RightEndpoint(a), RightEndpoint(b))
    left > right && return Interval{T}()
    return Interval{T}(left.endpoint, right.endpoint, left.included, right.included)
end

# There is power in a union.
"""
    union(intervals::AbstractVector{<:AbstractInterval})

Flattens a vector of overlapping intervals into a new, smaller vector containing only
non-overlapping intervals.
"""
function Base.union(intervals::AbstractVector{<:AbstractInterval})

    return union!(convert(Vector{AbstractInterval}, intervals))
end

"""
    union!(intervals::AbstractVector{<:AbstractInterval})

Flattens a vector of overlapping intervals in-place to be a smaller vector containing only
non-overlapping intervals.
"""
function Base.union!(intervals::AbstractVector{<:AbstractInterval})
    sort!(intervals)

    i = 2
    n = length(intervals)
    while i <= n
        prev = intervals[i - 1]
        curr = intervals[i]

        # If the current and previous intervals don't intersect then move along
        if isempty(intersect(prev, curr))
            i = i + 1

        # If the two intervals intersect then we absorb the current interval into
        # the previous one.
        else
            intervals[i - 1] = merge(prev, curr)
            deleteat!(intervals, i)
            n = n - 1
        end
    end

    return intervals
end

##### TIME ZONES #####

function astimezone(i::Interval{ZonedDateTime}, tz::TimeZone)
    return Interval(astimezone(first(i), tz), astimezone(last(i), tz), inclusivity(i))
end
