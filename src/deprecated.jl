using Base: @deprecate, depwarn
import Dates: Date, DateTime

# BEGIN Intervals 1.X.Y deprecations

export Inclusivity, inclusivity
include("inclusivity.jl")

function inclusivity(interval::AbstractInterval{T,L,R}) where {T,L,R}
    depwarn("`inclusivity(interval)` is deprecated and has no direct replacement. See `bounds_types(interval)` for similar functionality.", :inclusivity)
    return Inclusivity(L === Closed, R === Closed; ignore_depwarn=true)
end

@deprecate union(intervals::AbstractVector{<:AbstractInterval}) convert(Vector, union(IntervalSet(intervals)))
@deprecate union!(intervals::AbstractVector{<:AbstractInterval}) convert(Vector, union!(IntervalSet(intervals)))
@deprecate superset(intervals::AbstractVector{<:AbstractInterval}) superset(IntervalSet(intervals))

# END Intervals 1.X.Y deprecations
