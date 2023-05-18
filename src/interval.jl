"""
    Interval{T}

An `Interval` represents a non-iterable range or span of values (non-iterable because,
unlike a `StepRange`, no step is defined).

An `Interval` can be closed (both `first` and `last` are included in the interval), open
(neither `first` nor `last` are included), or half-open. This openness is defined by the
bounds information which is stored as the type parameters `L` and `R`.

### Example

```julia
julia> interval = Interval(0, 100, (Closed, Open))
Interval{Int64}(0, 100, 0x01)

julia> 0 in interval
true

julia> 50 in interval
true

julia> 100 in interval
false

julia> intersect(Interval(0, 25, (Open,Open)), Interval(20, 50, (Closed,Closed))
Interval{Int64}(20, 25, (Closed, Closed))
```

### Infix Constructor: `..`

A closed `Interval` can be constructed with the `..` infix constructor:

```julia
julia> Dates.today() - Dates.Week(1) .. Dates.today()
Interval{Date}(2018-01-24, 2018-01-31, (Closed, Closed))
```

See also: [`AnchoredInterval`](@ref)
"""
struct Interval{T} <: AbstractInterval{T}
    bounds::UInt8  # bounds comes first to allow incomplete construction for unbounded intervals
    first::T
    last::T

    # Internal constructors handle bounds conversions and argument ordering.
    function Interval{T}(f::T, l::T, bounds::Union{Tuple, UInt8}=(Closed, Closed)) where {T}
        f ≤ l || throw(ArgumentError("$f must be less than or equal to $l"))
        b = bounds isa Tuple ? bounds_int(bounds...) : bounds
        return new{T}(b, f, l)
    end

    # Handle nothings
    function Interval{T}(f::Nothing, l::T, bounds::Union{Tuple, UInt8}=(Unbounded, Closed)) where {T}
        if !(l ≤ l)
            throw(ArgumentError(
                "Unable to determine an ordering between $l and other values of type $T"
            ))
        end
        b = bounds isa Tuple ? bounds_int(bounds...) : bounds
        0x06 ≤ b ≤  0x07 || throw(ArgumentError("Left endpoint must be unbounded and the right must be bounded: $bounds"))
        return new{T}(b, l, l)
    end

    function Interval{T}(f::T, l::Nothing, bounds::Union{Tuple, UInt8}=(Closed, Unbounded)) where {T}
        if !(f ≤ f)
            throw(ArgumentError(
                "Unable to determine an ordering between $f and other values of type $T"
            ))
        end
        b = bounds isa Tuple ? bounds_int(bounds...) : bounds
        0x04 ≤ b ≤  0x05 || throw(ArgumentError("Left endpoint must be bounded and the right must be unbounded: $bounds"))
        return new{T}(b, f, f)
    end

    # Uses partial constructions
    function Interval{T}(f::Nothing, l::Nothing, bounds::Union{Tuple, UInt8}=(Unbounded, Unbounded)) where {T}
        b = bounds isa Tuple ? bounds_int(bounds...) : bounds
        b == 0x08 || throw(ArgumentError("Both endpoints must be unbounded: $bounds"))
        return new{T}(b)
    end
end

# Constructor to promote and converts to type T
Interval{T}(f, l, args...) where T = Interval{T}(convert(T, f), convert(T, l), args...)
Interval{T}(f, l::Nothing, args...) where T = Interval{T}(convert(T, f), l, args...)
Interval{T}(f::Nothing, l, args...) where T = Interval{T}(f, convert(T, l), args...)

Interval(f::T, l::T, args...) where T = Interval{T}(f, l, args...)
Interval(f, l, args...) = Interval(promote(f, l)..., args...)
Interval(f::Nothing, l::T, args...) where T = Interval{T}(f, l, args...)
Interval(f::T, l::Nothing, args...) where T = Interval{T}(f, l, args...)
Interval(f::Nothing, l::Nothing, args...) = Interval{Nothing}(f, l, args...)

(..)(first, last) = Interval(first, last)

# In Julia 0.7 constructors no longer automatically fall back to using `convert`
Interval(interval::AbstractInterval) = convert(Interval, interval)
Interval{T}(interval::AbstractInterval) where T = convert(Interval{T}, interval)

# Endpoint constructors
function Interval{T}(left::LeftEndpoint{T, L}, right::RightEndpoint{T, R}) where {T, L, R}
    return Interval{T}(endpoint(left), endpoint(right), bounds_int(L, R))
end

function Interval{T}(left::LeftEndpoint, right::RightEndpoint) where T
    return Interval{T}(
        endpoint(left),
        endpoint(right),
        (bound_type(left), bound_type(right)),
    )
end

function Interval(left::LeftEndpoint{S}, right::RightEndpoint{T}) where {S,T}
    return Interval{promote_type(S, T)}(left, right)
end

# Empty Intervals
Interval{T}() where T = Interval{T}(zero(T), zero(T), (Open, Open))
Interval{T}() where T <: TimeType = Interval{T}(T(0), T(0), (Open, Open))

function Interval{T}() where T <: ZonedDateTime
    return Interval{T}(T(0, tz"UTC"), T(0, tz"UTC"), (Open, Open))
end

Base.copy(x::T) where T <: Interval = T(x.first, x.last, x.bounds)

# TODO: Move this to Intervals.jl since it isn't specific to
function Base.hash(interval::AbstractInterval, h::UInt)
    h = hash(LeftEndpoint(interval), h)
    h = hash(RightEndpoint(interval), h)
    return h
end

##### ACCESSORS #####

# TODO: Drop these in favour of leftendpoint and rigthendpoint from IntervalSets.jl
function Base.first(interval::Interval)
    L, _ = bounds_types(interval)
    return L !== Unbounded ? interval.first : nothing
end

function Base.last(interval::Interval)
    _, R = bounds_types(interval)
    return R !== Unbounded ? interval.last : nothing
end

function span(interval::Interval)
    if isbounded(interval)
        interval.last - interval.first
    else
        throw(DomainError(
            "unbounded enpoint(s)",
            "Unable to determine the span of the non-bounded interval",
        ))
    end
end

bounds_int(interval::Interval) = interval.bounds
bounds_types(interval::Interval) = bounds_types(interval.bounds)


isclosed(interval::AbstractInterval) = bounds_types(interval) === (Closed, Closed)
Base.isopen(interval::AbstractInterval) = bounds_types(interval) === (Open, Open)
isbounded(interval::AbstractInterval) = bounds_int(interval) ≤ 0x03
isunbounded(interval::AbstractInterval) = !isbounded(interval)

function Base.minimum(interval::AbstractInterval{T}; kwargs...) where {T}
    L, _ = bounds_types(interval)
    L === Unbounded && return typemin(T)
    L === Closed && return first(interval)

    isempty(interval) && throw(BoundsError(interval, 0))
    return _minimum(interval; kwargs...)
end

function _minimum(interval::AbstractInterval{T}; increment=eps(T)) where {T}
    min_val = first(interval) + increment
    # Since intervals can't have NaN, we can just use !isfinite to check if infinite
    !isfinite(min_val) && return typemin(T)
    min_val ∈ interval && return min_val
    throw(BoundsError(interval, min_val))
end

function _minimum(interval::AbstractInterval{T}) where {T<:Integer}
    return _minimum(interval, increment=one(T))
end

function _minimum(interval::AbstractInterval{T}; increment=nothing) where {T<:AbstractFloat}
    min_val = first(interval)
    # Since intervals can't have NaN, we can just use !isfinite to check if infinite
    next_val = if !isfinite(min_val) || increment === nothing
        nextfloat(min_val)
    else
        min_val + increment
    end
    next_val ∈ interval && return next_val
    throw(BoundsError(interval, next_val))
end

function Base.maximum(interval::AbstractInterval{T}; kwargs...) where {T}
    _, R = bounds_types(interval)
    R === Unbounded && return typemax(T)
    R === Closed && return last(interval)

    isempty(interval) && throw(BoundsError(interval, 0))
    return _maximum(interval; kwargs...)
end

function _maximum(interval::AbstractInterval{T}; increment=eps(T)) where {T}
    max_val = last(interval) - increment
    # Since intervals can't have NaN, we can just use !isfinite to check if infinite
    !isfinite(max_val) && return typemax(T)
    max_val ∈ interval && return max_val
    throw(BoundsError(interval, max_val))
end

function _maximum(interval::AbstractInterval{T}) where {T<:Integer}
    return _maximum(interval, increment=one(T))
end

function _maximum(interval::AbstractInterval{T}; increment=nothing) where {T<:AbstractFloat}
    max_val = last(interval)
    next_val = if !isfinite(max_val) || increment === nothing
        prevfloat(max_val)
    else
        max_val - increment
    end
    next_val ∈ interval && return next_val
    throw(BoundsError(interval, next_val))
end

##### CONVERSION #####

# Allows an interval to be converted to a scalar when the set contained by the interval only
# contains a single element.
function Base.convert(::Type{T}, interval::Interval{T}) where T
    if first(interval) == last(interval) && isclosed(interval)
        return first(interval)
    else
        throw(DomainError(interval, "The interval is not closed with coinciding endpoints"))
    end
end

##### DISPLAY #####


function Base.show(io::IO, interval::Interval)
    if get(io, :compact, false)
        print(io, interval)
    else
        L, R = bounds_types(interval)
        print(io, "$(typeof(interval))(")
        L === Unbounded ? print(io, "nothing") : show(io, interval.first)
        print(io, ", ")
        R === Unbounded ? print(io, "nothing") : show(io, interval.last)
        print(io, ", ")
        show(io, bounds_types(interval))
        print(io, ")")
    end
end

function Base.print(io::IO, interval::AbstractInterval)
    # Print to io in order to keep properties like :limit and :compact
    if get(io, :compact, false)
        io = IOContext(io, :limit=>true)
    end

    L, R = bounds_types(interval)

    print(
        io,
        L === Closed ? "[" : "(",
        L === Unbounded ? "" : first(interval),
        " .. ",
        R === Unbounded ? "" : last(interval),
        R === Closed ? "]" : ")",
    )
end

##### ARITHMETIC #####

Base.:+(a::T, b) where {T <: Interval} = T(first(a) + b, last(a) + b, bounds_int(a))

Base.:+(a, b::Interval) = b + a
Base.:-(a::Interval, b) = a + -b
Base.:-(a, b::Interval) = a + -b
Base.:-(a::Interval{T}) where {T} = Interval{T}(-last(a), -first(a), bounds_int(a))

##### EQUALITY #####

function Base.:(==)(a::AbstractInterval, b::AbstractInterval)
    return LeftEndpoint(a) == LeftEndpoint(b) && RightEndpoint(a) == RightEndpoint(b)
end

function Base.isequal(a::AbstractInterval, b::AbstractInterval)
    le = isequal(LeftEndpoint(a), LeftEndpoint(b))
    re = isequal(RightEndpoint(a), RightEndpoint(b))
    return le && re
end

# While it might be convincingly argued that this should define < instead of isless (see
# https://github.com/invenia/Intervals.jl/issues/14), this breaks sort.
Base.isless(a::AbstractInterval, b) = LeftEndpoint(a) < b
Base.isless(a, b::AbstractInterval) = a < LeftEndpoint(b)

less_than_disjoint(a::AbstractInterval, b) = RightEndpoint(a) < b
less_than_disjoint(a, b::AbstractInterval) = a < LeftEndpoint(b)

function Base.isless(a::AbstractInterval, b::AbstractInterval)
    return LeftEndpoint(a) < LeftEndpoint(b)
end

function less_than_disjoint(a::AbstractInterval, b::AbstractInterval)
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

Base.in(a, b::AbstractInterval) = !(a ≫ b || a ≪ b)

function Base.in(a::AbstractInterval, b::AbstractInterval)
    # Intervals should be compared with set operations
    throw(ArgumentError("Intervals can not be compared with `in`. Use `issubset` instead."))
end

function Base.issubset(a::AbstractInterval, b::AbstractInterval)
    return LeftEndpoint(a) ≥ LeftEndpoint(b) && RightEndpoint(a) ≤ RightEndpoint(b)
end

function Base.isdisjoint(a::AbstractInterval, b::AbstractInterval)
    return RightEndpoint(a) < LeftEndpoint(b) || LeftEndpoint(a) > RightEndpoint(b)
end

Base.:⊈(a::AbstractInterval, b::AbstractInterval) = !issubset(a, b)
Base.:⊉(a::AbstractInterval, b::AbstractInterval) = !issubset(b, a)

function overlaps(a::AbstractInterval, b::AbstractInterval)
    left = max(LeftEndpoint(a), LeftEndpoint(b))
    right = min(RightEndpoint(a), RightEndpoint(b))

    return left <= right
end

function contiguous(a::AbstractInterval, b::AbstractInterval)
    left = max(LeftEndpoint(a), LeftEndpoint(b))
    right = min(RightEndpoint(a), RightEndpoint(b))

    return (
        !isunbounded(right) && !isunbounded(left) &&
        right.endpoint == left.endpoint && isclosed(left) != isclosed(right)
    )
end

function Base.intersect(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    !overlaps(a,b) && return Interval{T}()
    left = max(LeftEndpoint(a), LeftEndpoint(b))
    right = min(RightEndpoint(a), RightEndpoint(b))

    return Interval{T}(left, right)
end

function Base.intersect(a::AbstractInterval{S}, b::AbstractInterval{T}) where {S,T}
    !overlaps(a, b) && return Interval{promote_type(S, T)}()
    left = max(LeftEndpoint(a), LeftEndpoint(b))
    right = min(RightEndpoint(a), RightEndpoint(b))

    return Interval(left, right)
end

function Base.merge(a::AbstractInterval, b::AbstractInterval)
    if !overlaps(a, b) && !contiguous(a, b)
        throw(ArgumentError("$a and $b are neither overlapping or contiguous."))
    end

    left = min(LeftEndpoint(a), LeftEndpoint(b))
    right = max(RightEndpoint(a), RightEndpoint(b))
    return Interval(left, right)
end

##### ROUNDING #####
const RoundingFunctionTypes = Union{typeof(floor), typeof(ceil), typeof(round)}

for f in (:floor, :ceil, :round)
    @eval begin
        """
           $($f)(interval::Interval, args...; on::Symbol)

        Round the interval by applying `$($f)` to a single endpoint, then shifting the
        interval so that the span remains the same. The `on` keyword determines which
        endpoint the rounding will be applied to. Valid options are `:left` or `:right`.
        """
        function Base.$f(interval::Interval, args...; on::Symbol)
            return _round($f, interval, Val(on), args...)
        end
    end
end

function _round(f::RoundingFunctionTypes, interval::Interval, on::Val{:anchor}, args...)
    throw(ArgumentError(":anchor is only usable with an AnchoredInterval."))
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T}, on::Val{:left}, args...
) where {T}
    L, R = bounds_types(interval)
    L === Unbounded && return interval

    left_val = f(first(interval), args...)
    right_val = R <: Bounded ? left_val + span(interval) : nothing
    return Interval{T}(left_val, right_val, interval.bounds)
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T}, on::Val{:right}, args...
) where {T}
    L, R = bounds_types(interval)
    R === Unbounded && return interval

    right_val = f(last(interval), args...)
    left_val = L <: Bounded ? right_val - span(interval) : nothing
    return Interval{T}(left_val, right_val, interval.bounds)
end

##### TIME ZONES #####

function TimeZones.astimezone(i::Interval{T}, tz::TimeZone) where {T}
    return Interval{ZonedDateTime}(astimezone(first(i), tz), astimezone(last(i), tz), i.bounds)
end

function TimeZones.timezone(i::Interval)
    if timezone(first(i)) != timezone(last(i))
        throw(ArgumentError("Interval $i contains mixed timezones."))
    end
    return timezone(first(i))
end
