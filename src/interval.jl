"""
    Interval{T, L <: Bound, R <: Bound}

An `Interval` represents a non-iterable range or span of values (non-interable because,
unlike a `StepRange`, no step is defined).

An `Interval` can be closed (both `first` and `last` are included in the interval), open
(neither `first` nor `last` are included), or half-open. This openness is defined by the
bounds information which is stored as the type parameters `L` and `R`.

### Example

```julia
julia> interval = Interval{Closed,Open}(0, 100)
Interval{Int64,Closed,Open}}(0, 100)

julia> 0 in interval
true

julia> 50 in interval
true

julia> 100 in interval
false

julia> intersect(Interval{Open,Open}(0, 25), Interval{Closed,Closed}(20, 50)
Interval{Int64,Closed,Open}(20, 25)
```

### Infix Constructor: `..`

A closed `Interval` can be constructed with the `..` infix constructor:

```julia
julia> Dates.today() - Dates.Week(1) .. Dates.today()
Interval{Date,Closed,Closed}(2018-01-24, 2018-01-31)
```

### Multi-interval set operations

Set operations can also be performed over two pairs of interval arrays. These set
operations take the form of `op(x::Vector{<:Interval}, y::Vector{<:Interval})` and
interpret `x` and `y` as representing a set covered by the provided intervals. The return
value is an array of non-overlapping intervals representing the result of `op` over these
sets. You can also pass a single interval to either argument
(e.g. `op(x::Interval, y::Vector{<:Interval})`).

These multi-interval set operations currently only support intervals that are bounded.

See also: [`AnchoredInterval`](@ref)
"""
struct Interval{T, L <: Bound, R <: Bound} <: AbstractInterval{T,L,R}
    first::T
    last::T

    function Interval{T,L,R}(f::T, l::T) where {T, L <: Bounded, R <: Bounded}
        # Ensure that `first` preceeds `last`.
        if f ≤ l
            return new{T,L,R}(f, l)
        elseif l ≤ f
            # Note: Most calls to this inner constructor will be from other constructors
            # which may make it hard to identify the source of this deprecation. Use
            # `--depwarn=error` to see a full stack trace.
            Base.depwarn(
                "Constructing an `Interval{T,X,Y}(x, y)` " *
                "where `x > y` is deprecated, use `Interval{T,Y,X}(y, x)` instead.",
                :Interval,
            )
            return new{T,R,L}(l, f)
        else
            throw(ArgumentError("Unable to determine an ordering between: $f and $l"))
        end
    end

    function Interval{T,L,R}(f::Nothing, l::T) where {T, L <: Unbounded, R <: Bounded}
        # Note: Using `<` enforces that the type `T` defines `isless`
        if !(l ≤ l)
            throw(ArgumentError(
                "Unable to determine an ordering between $l and other values of type $T"
            ))
        end
        return new{T,L,R}(l, l)
    end

    function Interval{T,L,R}(f::T, l::Nothing) where {T, L <: Bounded, R <: Unbounded}
        # Note: Using `<` enforces that the type `T` defines `isless`
        if !(f ≤ f)
            throw(ArgumentError(
                "Unable to determine an ordering between $f and other values of type $T"
            ))
        end
        return new{T,L,R}(f, f)
    end

    function Interval{T,L,R}(f::Nothing, l::Nothing) where {T, L <: Unbounded, R <: Unbounded}
        return new{T,L,R}()
    end
end

function Interval{T,L,R}(f, l) where {T, L <: Bounded, R <: Bounded}
    return Interval{T,L,R}(convert(T, f), convert(T, l))
end
function Interval{T,L,R}(f, l::Nothing) where {T, L <: Bounded, R <: Unbounded}
    return Interval{T,L,R}(convert(T, f), l)
end
function Interval{T,L,R}(f::Nothing, l) where {T, L <: Unbounded, R <: Bounded}
    return Interval{T,L,R}(f, convert(T, l))
end

Interval{L,R}(f::T, l::T) where {T,L,R} = Interval{T,L,R}(f, l)
Interval{L,R}(f, l) where {L,R} = Interval{promote_type(typeof(f), typeof(l)), L, R}(f, l)
Interval{L,R}(f::Nothing, l::T) where {T,L,R} = Interval{T,L,R}(f, l)
Interval{L,R}(f::T, l::Nothing) where {T,L,R} = Interval{T,L,R}(f, l)
Interval{L,R}(f::Nothing, l::Nothing) where {L,R} = Interval{Nothing,L,R}(f, l)

Interval{T}(f, l) where T = Interval{T, Closed, Closed}(f, l)
Interval{T}(f::Nothing, l) where T = Interval{T, Unbounded, Closed}(f, l)
Interval{T}(f, l::Nothing) where T = Interval{T, Closed, Unbounded}(f, l)
Interval{T}(f::Nothing, l::Nothing) where T = Interval{T, Unbounded, Unbounded}(f, l)

Interval(f::T, l::T) where T = Interval{T}(f, l)
Interval(f, l) = Interval(promote(f, l)...)
Interval(f::Nothing, l::T) where T = Interval{T}(f, l)
Interval(f::T, l::Nothing) where T = Interval{T}(f, l)
Interval(f::Nothing, l::Nothing) = Interval{Nothing}(f, l)

(..)(first, last) = Interval(first, last)

# In Julia 0.7 constructors no longer automatically fall back to using `convert`
Interval(interval::AbstractInterval) = convert(Interval, interval)
Interval{T}(interval::AbstractInterval) where T = convert(Interval{T}, interval)

# Endpoint constructors
function Interval{T}(left::LeftEndpoint{T,L}, right::RightEndpoint{T,R}) where {T,L,R}
    Interval{T,L,R}(endpoint(left), endpoint(right))
end

function Interval{T}(left::LeftEndpoint, right::RightEndpoint) where T
    Interval{T, bound_type(left), bound_type(right)}(endpoint(left), endpoint(right))
end

function Interval(left::LeftEndpoint{S}, right::RightEndpoint{T}) where {S,T}
    Interval{promote_type(S, T)}(left, right)
end

# Empty Intervals
Interval{T}() where T = Interval{T, Open, Open}(zero(T), zero(T))
Interval{T}() where T <: TimeType = Interval{T, Open, Open}(T(0), T(0))

function Interval{T}() where T <: ZonedDateTime
    return Interval{T, Open, Open}(T(0, tz"UTC"), T(0, tz"UTC"))
end

Base.copy(x::T) where T <: Interval = T(x.first, x.last)

function Base.hash(interval::AbstractInterval, h::UInt)
    h = hash(LeftEndpoint(interval), h)
    h = hash(RightEndpoint(interval), h)
    return h
end

##### ACCESSORS #####

function Base.first(interval::Interval{T,L,R}) where {T,L,R}
    return L !== Unbounded ? interval.first : nothing
end

function Base.last(interval::Interval{T,L,R}) where {T,L,R}
    return R !== Unbounded ? interval.last : nothing
end

function span(interval::Interval)
    if isbounded(interval)
        interval.last - interval.first
    else
        throw(DomainError(
            "unbounded endpoint(s)",
            "Unable to determine the span of an non-bounded interval",
        ))
    end
end

isclosed(interval::AbstractInterval{T,L,R}) where {T,L,R} = L === Closed && R === Closed
Base.isopen(interval::AbstractInterval{T,L,R}) where {T,L,R} = L === Open && R === Open
isunbounded(interval::AbstractInterval{T,L,R}) where {T,L,R} = L === Unbounded && R === Unbounded
isbounded(interval::AbstractInterval{T,L,R}) where {T,L,R} = L !== Unbounded && R !== Unbounded

function Base.minimum(interval::AbstractInterval{T,L,R}; increment=nothing) where {T,L,R}
    return L === Unbounded ? typemin(T) : first(interval)
end

function Base.minimum(interval::AbstractInterval{T,Open,R}; increment=eps(T)) where {T,R}
    isempty(interval) && throw(BoundsError(interval, 0))
    min_val = first(interval) + increment
    # Since intervals can't have NaN, we can just use !isfinite to check if infinite
    !isfinite(min_val) && return typemin(T)
    min_val ∈ interval && return min_val
    throw(BoundsError(interval, min_val))
end

function Base.minimum(interval::AbstractInterval{T,Open,R}) where {T<:Integer,R}
    return minimum(interval, increment=one(T))
end

function Base.minimum(interval::AbstractInterval{T,Open,R}; increment=nothing) where {T<:AbstractFloat,R}
    isempty(interval) && throw(BoundsError(interval, 0))
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

function Base.maximum(interval::AbstractInterval{T,L,R}; increment=nothing) where {T,L,R}
    return R === Unbounded ? typemax(T) : last(interval)
end

function Base.maximum(interval::AbstractInterval{T,L,Open}; increment=eps(T)) where {T,L}
    isempty(interval) && throw(BoundsError(interval, 0))
    max_val = last(interval) - increment
    # Since intervals can't have NaN, we can just use !isfinite to check if infinite
    !isfinite(max_val) && return typemax(T)
    max_val ∈ interval && return max_val
    throw(BoundsError(interval, max_val))
end

function Base.maximum(interval::AbstractInterval{T,L,Open}) where {T<:Integer,L}
    return maximum(interval, increment=one(T))
end

function Base.maximum(interval::AbstractInterval{T,L,Open}; increment=nothing) where {T<:AbstractFloat,L}
    isempty(interval) && throw(BoundsError(interval, 0))
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


function Base.show(io::IO, interval::Interval{T,L,R}) where {T,L,R}
    if get(io, :compact, false)
        print(io, interval)
    else
        print(io, "$(typeof(interval))(")
        L === Unbounded ? print(io, "nothing") : show(io, interval.first)
        print(io, ", ")
        R === Unbounded ? print(io, "nothing") : show(io, interval.last)
        print(io, ")")
    end
end

function Base.print(io::IO, interval::AbstractInterval{T,L,R}) where {T,L,R}
    # Print to io in order to keep properties like :limit and :compact
    if get(io, :compact, false)
        io = IOContext(io, :limit=>true)
    end

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

Base.:+(a::T, b) where {T <: Interval} = T(first(a) + b, last(a) + b)

Base.:+(a, b::Interval) = b + a
Base.:-(a::Interval, b) = a + -b
Base.:-(a, b::Interval) = a + -b
Base.:-(a::Interval{T,L,R}) where {T,L,R} = Interval{T,R,L}(-last(a), -first(a))

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

function Base.:isless(a::AbstractInterval, b::AbstractInterval)
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

Base.union(x::AbstractInterval) = x

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
    f::RoundingFunctionTypes, interval::Interval{T,L,R}, on::Val{:left}, args...
) where {T, L <: Bounded, R <: Bounded}
    left_val = f(first(interval), args...)
    return Interval{T,L,R}(left_val, left_val + span(interval))
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,R}, on::Val{:left}, args...
) where {T, L <: Bounded, R <: Unbounded}
    left_val = f(first(interval), args...)
    return Interval{T,L,R}(left_val, nothing)
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,R}, on::Val{:left}, args...
) where {T, L <: Unbounded, R <: Bound}
    return interval
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,R}, on::Val{:right}, args...
) where {T, L <: Bounded, R <: Bounded}
    right_val = f(last(interval), args...)
    return Interval{T,L,R}(right_val - span(interval), right_val)
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,R}, on::Val{:right}, args...
) where {T, L <: Unbounded, R <: Bounded}
    right_val = f(last(interval), args...)
    return Interval{T,L,R}(nothing, right_val)
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,R}, on::Val{:right}, args...
) where {T, L <: Bound, R <: Unbounded}
    return interval
end


##### TIME ZONES #####

function TimeZones.astimezone(i::Interval{ZonedDateTime, L, R}, tz::TimeZone) where {L,R}
    return Interval{ZonedDateTime, L, R}(astimezone(first(i), tz), astimezone(last(i), tz))
end

function TimeZones.timezone(i::Interval{ZonedDateTime})
    if timezone(first(i)) != timezone(last(i))
        throw(ArgumentError("Interval $i contains mixed timezones."))
    end
    return timezone(first(i))
end
