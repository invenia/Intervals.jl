using Base: @deprecate, depwarn
import Dates: Date, DateTime

# BEGIN Intervals 1.X.Y deprecations

@deprecate union(intervals::AbstractVector{<:AbstractInterval}) convert(Vector, union(IntervalSet(intervals)))
@deprecate union!(intervals::AbstractVector{<:AbstractInterval}) convert(Vector, union!(IntervalSet(intervals)))
@deprecate superset(intervals::AbstractVector{<:AbstractInterval}) superset(IntervalSet(intervals))

# END Intervals 1.X.Y deprecations
