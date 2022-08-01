"""
    Interval{T, L <: Bound, U <: Bound}

An `Interval` represents a non-iterable range or span of values (non-interable because,
unlike a `StepRange`, no step is defined).

An `Interval` can be closed (both `lowerbound` and `upperbound` are included in the interval), open
(neither `lowerbound` nor `upperbound` are included), or half-open. This openness is defined by the
bounds information which is stored as the type parameters `L` and `U`.

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

See also: [`AnchoredInterval`](@ref)
"""
struct Interval{T, L <: Bound, U <: Bound} <: AbstractInterval{T,L,U}
    lowerbound::T
    upperbound::T

    function Interval{T,L,U}(f::T, l::T) where {T, L <: Bounded, U <: Bounded}
        # Ensure that `lowerbound` preceeds `upperbound`.
        if f ≤ l
            return new{T,L,U}(f, l)
        elseif l ≤ f
            # Note: Most calls to this inner constructor will be from other constructors
            # which may make it hard to identify the source of this deprecation. Use
            # `--depwarn=error` to see a full stack trace.
            Base.depwarn(
                "Constructing an `Interval{T,X,Y}(x, y)` " *
                "where `x > y` is deprecated, use `Interval{T,Y,X}(y, x)` instead.",
                :Interval,
            )
            return new{T,U,L}(l, f)
        else
            throw(ArgumentError("Unable to determine an ordering between: $f and $l"))
        end
    end

    function Interval{T,L,U}(f::Nothing, l::T) where {T, L <: Unbounded, U <: Bounded}
        # Note: Using `<` enforces that the type `T` defines `isless`
        if !(l ≤ l)
            throw(ArgumentError(
                "Unable to determine an ordering between $l and other values of type $T"
            ))
        end
        return new{T,L,U}(l, l)
    end

    function Interval{T,L,U}(f::T, l::Nothing) where {T, L <: Bounded, U <: Unbounded}
        # Note: Using `<` enforces that the type `T` defines `isless`
        if !(f ≤ f)
            throw(ArgumentError(
                "Unable to determine an ordering between $f and other values of type $T"
            ))
        end
        return new{T,L,U}(f, f)
    end

    function Interval{T,L,U}(f::Nothing, l::Nothing) where {T, L <: Unbounded, U <: Unbounded}
        return new{T,L,U}()
    end
end

function Interval{T,L,U}(f, l) where {T, L <: Bounded, U <: Bounded}
    return Interval{T,L,U}(convert(T, f), convert(T, l))
end
function Interval{T,L,U}(f, l::Nothing) where {T, L <: Bounded, U <: Unbounded}
    return Interval{T,L,U}(convert(T, f), l)
end
function Interval{T,L,U}(f::Nothing, l) where {T, L <: Unbounded, U <: Bounded}
    return Interval{T,L,U}(f, convert(T, l))
end

Interval{L,U}(f::T, l::T) where {T,L,U} = Interval{T,L,U}(f, l)
Interval{L,U}(f, l) where {L,U} = Interval{promote_type(typeof(f), typeof(l)), L, U}(f, l)
Interval{L,U}(f::Nothing, l::T) where {T,L,U} = Interval{T,L,U}(f, l)
Interval{L,U}(f::T, l::Nothing) where {T,L,U} = Interval{T,L,U}(f, l)
Interval{L,U}(f::Nothing, l::Nothing) where {L,U} = Interval{Nothing,L,U}(f, l)

Interval{T}(f, l) where T = Interval{T, Closed, Closed}(f, l)
Interval{T}(f::Nothing, l) where T = Interval{T, Unbounded, Closed}(f, l)
Interval{T}(f, l::Nothing) where T = Interval{T, Closed, Unbounded}(f, l)
Interval{T}(f::Nothing, l::Nothing) where T = Interval{T, Unbounded, Unbounded}(f, l)

Interval(f::T, l::T) where T = Interval{T}(f, l)
Interval(f, l) = Interval(promote(f, l)...)
Interval(f::Nothing, l::T) where T = Interval{T}(f, l)
Interval(f::T, l::Nothing) where T = Interval{T}(f, l)
Interval(f::Nothing, l::Nothing) = Interval{Nothing}(f, l)

(..)(lowerbound, upperbound) = Interval(lowerbound, upperbound)

# In Julia 0.7 constructors no longer automatically fall back to using `convert`
Interval(interval::AbstractInterval) = convert(Interval, interval)
Interval{T}(interval::AbstractInterval) where T = convert(Interval{T}, interval)

# Endpoint constructors
function Interval{T}(lower::LowerEndpoint{T,L}, upper::UpperEndpoint{T,U}) where {T,L,U}
    Interval{T,L,U}(endpoint(lower), endpoint(upper))
end

function Interval{T}(lower::LowerEndpoint, upper::UpperEndpoint) where T
    Interval{T, bound_type(lower), bound_type(upper)}(endpoint(lower), endpoint(upper))
end

function Interval(lower::LowerEndpoint{S}, upper::UpperEndpoint{T}) where {S,T}
    Interval{promote_type(S, T)}(lower, upper)
end

# Empty Intervals
Interval{T}() where T = Interval{T, Open, Open}(zero(T), zero(T))
Interval{T}() where T <: TimeType = Interval{T, Open, Open}(T(0), T(0))

function Interval{T}() where T <: ZonedDateTime
    return Interval{T, Open, Open}(T(0, tz"UTC"), T(0, tz"UTC"))
end

Base.copy(x::T) where T <: Interval = T(x.lowerbound, x.upperbound)

function Base.hash(interval::AbstractInterval, h::UInt)
    h = hash(LowerEndpoint(interval), h)
    h = hash(UpperEndpoint(interval), h)
    return h
end

##### ACCESSORS #####

function lowerbound(interval::Interval{T,L,U}) where {T,L,U}
    return L !== Unbounded ? interval.lowerbound : nothing
end

function upperbound(interval::Interval{T,L,U}) where {T,L,U}
    return U !== Unbounded ? interval.upperbound : nothing
end

function span(interval::Interval)
    if isbounded(interval)
        interval.upperbound - interval.lowerbound
    else
        throw(DomainError(
            "unbounded endpoint(s)",
            "Unable to determine the span of an non-bounded interval",
        ))
    end
end

isclosed(interval::AbstractInterval{T,L,U}) where {T,L,U} = L === Closed && U === Closed
Base.isopen(interval::AbstractInterval{T,L,U}) where {T,L,U} = L === Open && U === Open
isunbounded(interval::AbstractInterval{T,L,U}) where {T,L,U} = L === Unbounded && U === Unbounded
isbounded(interval::AbstractInterval{T,L,U}) where {T,L,U} = L !== Unbounded && U !== Unbounded

function Base.minimum(interval::AbstractInterval{T,L,U}; increment=nothing) where {T,L,U}
    return L === Unbounded ? typemin(T) : lowerbound(interval)
end

function Base.minimum(interval::AbstractInterval{T,Open,U}; increment=eps(T)) where {T,U}
    isempty(interval) && throw(BoundsError(interval, 0))
    min_val = lowerbound(interval) + increment
    # Since intervals can't have NaN, we can just use !isfinite to check if infinite
    !isfinite(min_val) && return typemin(T)
    min_val ∈ interval && return min_val
    throw(BoundsError(interval, min_val))
end

function Base.minimum(interval::AbstractInterval{T,Open,U}) where {T<:Integer,U}
    return minimum(interval, increment=one(T))
end

function Base.minimum(interval::AbstractInterval{T,Open,U}; increment=nothing) where {T<:AbstractFloat,U}
    isempty(interval) && throw(BoundsError(interval, 0))
    min_val = lowerbound(interval)
    # Since intervals can't have NaN, we can just use !isfinite to check if infinite
    next_val = if !isfinite(min_val) || increment === nothing
        nextfloat(min_val)
    else
        min_val + increment
    end
    next_val ∈ interval && return next_val
    throw(BoundsError(interval, next_val))
end

function Base.maximum(interval::AbstractInterval{T,L,U}; increment=nothing) where {T,L,U}
    return U === Unbounded ? typemax(T) : upperbound(interval)
end

function Base.maximum(interval::AbstractInterval{T,L,Open}; increment=eps(T)) where {T,L}
    isempty(interval) && throw(BoundsError(interval, 0))
    max_val = upperbound(interval) - increment
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
    max_val = upperbound(interval)
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
    if lowerbound(interval) == upperbound(interval) && isclosed(interval)
        return lowerbound(interval)
    else
        throw(DomainError(interval, "The interval is not closed with coinciding endpoints"))
    end
end

##### DISPLAY #####


function Base.show(io::IO, interval::Interval{T,L,U}) where {T,L,U}
    if get(io, :compact, false)
        print(io, interval)
    else
        print(io, "$(typeof(interval))(")
        L === Unbounded ? print(io, "nothing") : show(io, interval.lowerbound)
        print(io, ", ")
        U === Unbounded ? print(io, "nothing") : show(io, interval.upperbound)
        print(io, ")")
    end
end

function Base.print(io::IO, interval::AbstractInterval{T,L,U}) where {T,L,U}
    # Print to io in order to keep properties like :limit and :compact
    if get(io, :compact, false)
        io = IOContext(io, :limit=>true)
    end

    print(
        io,
        L === Closed ? "[" : "(",
        L === Unbounded ? "" : lowerbound(interval),
        " .. ",
        U === Unbounded ? "" : upperbound(interval),
        U === Closed ? "]" : ")",
    )
end

##### ARITHMETIC #####

Base.:+(a::T, b) where {T <: Interval} = T(lowerbound(a) + b, upperbound(a) + b)

Base.:+(a, b::Interval) = b + a
Base.:-(a::Interval, b) = a + -b
Base.:-(a, b::Interval) = a + -b
Base.:-(a::Interval{T,L,U}) where {T,L,U} = Interval{T,U,L}(-upperbound(a), -lowerbound(a))

##### EQUALITY #####

function Base.:(==)(a::AbstractInterval, b::AbstractInterval)
    return LowerEndpoint(a) == LowerEndpoint(b) && UpperEndpoint(a) == UpperEndpoint(b)
end

function Base.isequal(a::AbstractInterval, b::AbstractInterval)
    le = isequal(LowerEndpoint(a), LowerEndpoint(b))
    re = isequal(UpperEndpoint(a), UpperEndpoint(b))
    return le && re
end

# While it might be convincingly argued that this should define < instead of isless (see
# https://github.com/invenia/Intervals.jl/issues/14), this breaks sort.
Base.isless(a::AbstractInterval, b) = LowerEndpoint(a) < b
Base.isless(a, b::AbstractInterval) = a < LowerEndpoint(b)

less_than_disjoint(a::AbstractInterval, b) = UpperEndpoint(a) < b
less_than_disjoint(a, b::AbstractInterval) = a < LowerEndpoint(b)

function Base.:isless(a::AbstractInterval, b::AbstractInterval)
    return LowerEndpoint(a) < LowerEndpoint(b)
end

function less_than_disjoint(a::AbstractInterval, b::AbstractInterval)
    return UpperEndpoint(a) < LowerEndpoint(b)
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

Base.isempty(i::AbstractInterval) = LowerEndpoint(i) > UpperEndpoint(i)
Base.in(a, b::AbstractInterval) = !(a ≫ b || a ≪ b)

function Base.in(a::AbstractInterval, b::AbstractInterval)
    # Intervals should be compared with set operations
    throw(ArgumentError("Intervals can not be compared with `in`. Use `issubset` instead."))
end

function Base.issubset(a::AbstractInterval, b::AbstractInterval)
    return LowerEndpoint(a) ≥ LowerEndpoint(b) && UpperEndpoint(a) ≤ UpperEndpoint(b)
end

function Base.isdisjoint(a::AbstractInterval, b::AbstractInterval)
    return UpperEndpoint(a) < LowerEndpoint(b) || LowerEndpoint(a) > UpperEndpoint(b)
end

Base.:⊈(a::AbstractInterval, b::AbstractInterval) = !issubset(a, b)
Base.:⊉(a::AbstractInterval, b::AbstractInterval) = !issubset(b, a)

function overlaps(a::AbstractInterval, b::AbstractInterval)
    lower = max(LowerEndpoint(a), LowerEndpoint(b))
    upper = min(UpperEndpoint(a), UpperEndpoint(b))

    return lower <= upper
end

function contiguous(a::AbstractInterval, b::AbstractInterval)
    lower = max(LowerEndpoint(a), LowerEndpoint(b))
    upper = min(UpperEndpoint(a), UpperEndpoint(b))

    return (
        !isunbounded(upper) && !isunbounded(lower) &&
        upper.endpoint == lower.endpoint && isclosed(lower) != isclosed(upper)
    )
end

function Base.intersect(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    !overlaps(a,b) && return Interval{T}()
    lower = max(LowerEndpoint(a), LowerEndpoint(b))
    upper = min(UpperEndpoint(a), UpperEndpoint(b))

    return Interval{T}(lower, upper)
end

function Base.intersect(a::AbstractInterval{S}, b::AbstractInterval{T}) where {S,T}
    !overlaps(a, b) && return Interval{promote_type(S, T)}()
    lower = max(LowerEndpoint(a), LowerEndpoint(b))
    upper = min(UpperEndpoint(a), UpperEndpoint(b))

    return Interval(lower, upper)
end

function Base.merge(a::AbstractInterval, b::AbstractInterval)
    if !overlaps(a, b) && !contiguous(a, b)
        throw(ArgumentError("$a and $b are neither overlapping or contiguous."))
    end

    lower = min(LowerEndpoint(a), LowerEndpoint(b))
    upper = max(UpperEndpoint(a), UpperEndpoint(b))
    return Interval(lower, upper)
end

##### ROUNDING #####
const RoundingFunctionTypes = Union{typeof(floor), typeof(ceil), typeof(round)}

for f in (:floor, :ceil, :round)
    @eval begin
        """
           $($f)(interval::Interval, args...; on::Symbol)

        Round the interval by applying `$($f)` to a single endpoint, then shifting the
        interval so that the span remains the same. The `on` keyword determines which
        endpoint the rounding will be applied to. Valid options are `:lower` or `:upper`.
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
    f::RoundingFunctionTypes, interval::Interval{T,L,U}, on::Val{:lower}, args...
) where {T, L <: Bounded, U <: Bounded}
    lower_val = f(lowerbound(interval), args...)
    return Interval{T,L,U}(lower_val, lower_val + span(interval))
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,U}, on::Val{:lower}, args...
) where {T, L <: Bounded, U <: Unbounded}
    lower_val = f(lowerbound(interval), args...)
    return Interval{T,L,U}(lower_val, nothing)
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,U}, on::Val{:lower}, args...
) where {T, L <: Unbounded, U <: Bound}
    return interval
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,U}, on::Val{:upper}, args...
) where {T, L <: Bounded, U <: Bounded}
    upper_val = f(upperbound(interval), args...)
    return Interval{T,L,U}(upper_val - span(interval), upper_val)
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,U}, on::Val{:upper}, args...
) where {T, L <: Unbounded, U <: Bounded}
    upper_val = f(upperbound(interval), args...)
    return Interval{T,L,U}(nothing, upper_val)
end

function _round(
    f::RoundingFunctionTypes, interval::Interval{T,L,U}, on::Val{:upper}, args...
) where {T, L <: Bound, U <: Unbounded}
    return interval
end


##### TIME ZONES #####

function TimeZones.astimezone(i::Interval{ZonedDateTime, L, U}, tz::TimeZone) where {L,U}
    return Interval{ZonedDateTime, L, U}(astimezone(lowerbound(i), tz), astimezone(upperbound(i), tz))
end

function TimeZones.timezone(i::Interval{ZonedDateTime})
    if timezone(lowerbound(i)) != timezone(upperbound(i))
        throw(ArgumentError("Interval $i contains mixed timezones."))
    end
    return timezone(lowerbound(i))
end
