# Note: Terminology overall taken from:
# https://en.wikipedia.org/wiki/Interval_(mathematics)#Terminology

"""
    Bound <: Any

Abstract type representing all possible endpoint classifications (e.g. open, closed,
unbounded).
"""
:Bound

"""
    Bounded <: Bound

Abstract type indicating that the endpoint of an interval is not unbounded (e.g. open or
closed).
"""
:Bounded

"""
    Closed <: Bounded <: Bound

Type indicating that the endpoint of an interval is closed (the endpoint value is *included*
in the interval).
"""
:Closed

"""
    Open <: Bounded <: Bound

Type indicating that the endpoint of an interval is open (the endpoint value is *not
included* in the interval).
"""
:Open

"""
    Unbounded <: Bound

Type indicating that the endpoint of an interval is unbounded (the endpoint value is
effectively infinite).
"""
:Unbounded

"""
    LeftEndpoint <: Endpoint

Represents the lower endpoint of an `AbstractInterval`. Useful for comparing two endpoints
to each other.

### Examples

```jldoctest; setup = :(using Intervals; using Intervals: LeftEndpoint)
julia> LeftEndpoint(Interval(0.0, 1.0))
Intervals.Endpoint{Float64,Intervals.Direction{:Left}(),Closed}(0.0)

julia> LeftEndpoint{Closed}(1.0)
Intervals.Endpoint{Float64,Intervals.Direction{:Left}(),Closed}(1.0)

julia> LeftEndpoint{Integer, Closed}(1.0)
Intervals.Endpoint{Integer,Intervals.Direction{:Left}(),Closed}(1)
```

See also: [`RightEndpoint`](@ref)
"""
:LeftEndpoint

"""
    RightEndpoint <: Endpoint

Represents the upper endpoint of an `AbstractInterval`. Useful for comparing two endpoints
to each other.

### Examples

```jldoctest; setup = :(using Intervals; using Intervals: RightEndpoint)
julia> RightEndpoint(Interval(0.0, 1.0))
Intervals.Endpoint{Float64,Intervals.Direction{:Right}(),Closed}(1.0)

julia> RightEndpoint{Closed}(1.0)
Intervals.Endpoint{Float64,Intervals.Direction{:Right}(),Closed}(1.0)

julia> RightEndpoint{Integer, Closed}(1.0)
Intervals.Endpoint{Integer,Intervals.Direction{:Right}(),Closed}(1)
```

See also: [`LeftEndpoint`](@ref)
"""
:RightEndpoint

"""
    first(interval::AbstractInterval{T}) -> Union{T,Nothing}

The value of the lower endpoint. When the lower endpoint is unbounded `nothing` will be
returned.
"""
Base.first(::AbstractInterval)

"""
    last(interval::AbstractInterval{T}) -> Union{T,Nothing}

The value of the upper endpoint. When the upper endpoint is unbounded `nothing` will be
returned.
"""
Base.last(::AbstractInterval)

"""
    span(interval::AbstractInterval) -> Any

The delta between the upper and lower endpoints. For bounded intervals returns a
non-negative value while intervals with any unbounded endpoints will throw an
`ArgumentError`.

To avoid having to capture the exception use the pattern:
```julia
Intervals.isbounded(interval) ? span(interval) : infinity
```
Where `infinity` is a variable representing the value you wish to use to represent an
unbounded, or infinite, span.
"""
span(::AbstractInterval)

"""
    isclosed(interval) -> Bool

Is a closed-interval: includes both of its endpoints.
"""
isclosed(::AbstractInterval)

"""
    isopen(interval) -> Bool

Is an open-interval: excludes both of its endpoints.
"""
Base.isopen(::AbstractInterval)

"""
    isunbounded(interval) -> Bool

Is an unbounded-interval: unbounded at both ends.
"""
isunbounded(::AbstractInterval)

"""
    isbounded(interval) -> Bool

Is a bounded-interval: either open, closed, left-closed/right-open, or
left-open/right-closed.

Note using `!isbounded` is commonly used to determine if any end of the interval is
unbounded.
"""
isbounded(::AbstractInterval)

"""
    minimum(interval::AbstractInterval{T}; [increment]) -> T

The minimum value contained within the `interval`.

If left-closed, returns `first(interval)`.
If left-open, returns `first(interval) + eps(first(interval))`
If left-unbounded, returns minimum value possible for type `T`.

A `BoundsError` is thrown for empty intervals or when the increment results in a minimum value
not-contained by the interval.
"""
minimum(::AbstractInterval; increment)

"""
    maximum(interval::AbstractInterval{T}; [increment]) -> T

The maximum value contained within the `interval`.

If right-closed, returns `last(interval)`.
If right-open, returns `first(interval) + eps(first(interval))`
If right-unbounded, returns maximum value possible for type `T`.

A `BoundsError` is thrown for empty intervals or when the increment results in a maximum value
not-contained by the interval.
"""
maximum(::AbstractInterval; increment)
