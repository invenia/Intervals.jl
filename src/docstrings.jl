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
!isbounded(interval) ? span(interval) : infinity`
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
