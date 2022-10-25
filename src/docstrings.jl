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
    LowerEndpoint <: Endpoint

Represents the lower endpoint of an `AbstractInterval`. Useful for comparing two endpoints
to each other.

!!! note

    An older name for `LowerEndpoint` is `LeftEndpoint`. It remains defined 
    as an alias to `LowerEndpoint` (to avoid breaking old code) but its use is discouraged.
    It is not deprecated (since types can't be deprecated).

### Examples

```jldoctest; setup = :(using Intervals; using Intervals: LowerEndpoint)
julia> LowerEndpoint(Interval(0.0, 1.0))
Intervals.Endpoint{Float64, Intervals.Direction{:Lower}(), Closed}(0.0)

julia> LowerEndpoint{Closed}(1.0)
Intervals.Endpoint{Float64, Intervals.Direction{:Lower}(), Closed}(1.0)

julia> LowerEndpoint{Closed}(1) < LowerEndpoint{Closed}(2)
true

julia> LowerEndpoint{Closed}(0) < LowerEndpoint{Open}(0)
true

julia> LowerEndpoint{Open}(0) <= LowerEndpoint{Closed}(0)
false
```

See also: [`UpperEndpoint`](@ref)
"""
:LowerEndpoint

"""
    UpperEndpoint <: Endpoint

Represents the upper endpoint of an `AbstractInterval`. Useful for comparing two endpoints
to each other.

!!! note

    An older name for `UpperEndpoint` is `RightEndpoint`. It remains defined 
    as an alias to `UpperEndpoint` (to avoid breaking old code) but its use is discouraged.
    It is not deprecated (since types can't be deprecated).

### Examples

```jldoctest; setup = :(using Intervals; using Intervals: UpperEndpoint)
julia> UpperEndpoint(Interval(0.0, 1.0))
Intervals.Endpoint{Float64, Intervals.Direction{:Upper}(), Closed}(1.0)

julia> UpperEndpoint{Closed}(1.0)
Intervals.Endpoint{Float64, Intervals.Direction{:Upper}(), Closed}(1.0)

julia> UpperEndpoint{Closed}(1) < UpperEndpoint{Closed}(2)
true

julia> UpperEndpoint{Open}(0) < UpperEndpoint{Closed}(0)
true

julia> UpperEndpoint{Closed}(0) <= UpperEndpoint{Open}(0)
false
```

See also: [`LowerEndpoint`](@ref)
"""
:UpperEndpoint

"""
    lowerbound(interval::AbstractInterval{T}) -> Union{T,Nothing}

The value of the lower endpoint. When the lower endpoint is unbounded `nothing` will be
returned.
"""
Base.lowerbound(::AbstractInterval)

"""
    upperbound(interval::AbstractInterval{T}) -> Union{T,Nothing}

The value of the upper endpoint. When the upper endpoint is unbounded `nothing` will be
returned.
"""
Base.upperbound(::AbstractInterval)

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

Is a bounded-interval: either open, closed, lower-closed/upper-open, or
lower-open/upper-closed.

Note using `!isbounded` is commonly used to determine if any end of the interval is
unbounded.
"""
isbounded(::AbstractInterval)

"""
    minimum(interval::AbstractInterval{T}; [increment]) -> T

The minimum value contained within the `interval`.

If lower-closed, returns `lowerbound(interval)`.
If lower-open, returns `lowerbound(interval) + eps(lowerbound(interval))`
If lower-unbounded, returns minimum value possible for type `T`.

A `BoundsError` is thrown for empty intervals or when the increment results in a minimum value
not-contained by the interval.
"""
minimum(::AbstractInterval; increment)

"""
    maximum(interval::AbstractInterval{T}; [increment]) -> T

The maximum value contained within the `interval`.

If upper-closed, returns `upperbound(interval)`.
If upper-open, returns `lowerbound(interval) + eps(lowerbound(interval))`
If upper-unbounded, returns maximum value possible for type `T`.

A `BoundsError` is thrown for empty intervals or when the increment results in a maximum value
not-contained by the interval.
"""
maximum(::AbstractInterval; increment)
