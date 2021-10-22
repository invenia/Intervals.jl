"""
    Interval{T, L <: Bound, R <: Bound}

An `Interval` represents a non-iterable range or span of values (non-interable
because, unlike a `StepRange`, no step is defined).

An `Interval` can be closed (both `first` and `last` are included in the
interval), open (neither `first` nor `last` are included), or half-open. This
openness is defined by the bounds information which is stored as the type
parameters `L` and `R`.

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

### Set operations

General set operations can be performed over arrays of intervals. These set
operations take the form of `op(x::Vector{<:Interval}, y::Vector{<:Interval})`
and return an array of non-overalping intervals representing the result. You can
also pass a single interval to either arugment. These set operations do not
currently support unbounded intervals.

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

###### Set-related Helpers #####

# Edge is used to represent the two bounds of an interval when merging sets
# of intervals
abstract type AbstractEdge{T}; end
struct Edge{T} <: AbstractEdge{T}
    value::T
    first::Bool
    index::Int
    closed::Bool
end
Edge(t, start = true, closed = true) = Edge{eltype(t)}(t, start, 0, closed)
Edge(t::Edge, start, closed) = Edge(t.value, start, closed)
isclosed(x::Edge) = x.closed
offset(x::AbstractEdge) = x.first ? !isclosed(x) : isclosed(x)
function Base.isless(x::AbstractEdge, y::AbstractEdge) 
    if isequal(x.value, y.value) 
        return isless(offset(x), offset(y)) 
    else 
        return isless(x.value, y.value)
    end
end
Base.isequal(x::AbstractEdge, y::AbstractEdge) = isequal(isclosed(x), isclosed(y)) && isequal(x.value, y.value)
Base.eltype(::AbstractEdge{T}) where T = T
Base.eltype(::Type{<:AbstractEdge{T}}) where T = T
"""
    startedge(interval)

A representation of the starting edge of an interval. Useful for proper sorting
of intervals (e.g. sort(intervals, by=startedge)). The difference between
sorting by `first` is that it properly accounts for `closed/open` edges.
"""
startedge(x::AbstractInterval{T,A}, i=0) where {T,A} = Edge{T}(first(x), true, i, A == Closed)

"""
    stopedge(interval)

A representation of the stopping edge of an interval. Useful for proper sorting
of intervals (e.g. sort(intervals, by=startedge)). The difference between
sorting by `first` is that it properly accounts for `closed/open` edges.
"""
stopedge(x::AbstractInterval{T,<:Any,B}, i=0) where {T,B} = Edge{T}(last(x), false, i, B == Closed)
isstart(x::AbstractEdge) = x.first

function Interval(x::Edge{T}, y::Edge{S}) where {T, S} 
    return Interval{Union{T,S}, bound_type(isclosed(x)), 
                    bound_type(isclosed(y))}(x.value, y.value)
end

# EdgeDir is used to represent [a, b) (left) and (a, b] (right) intervals
# which are closed under set operations (so we can keep things type invariant
# if only left or only right intervals are present in an array)
struct EdgeDir{D,T} <: AbstractEdge{T}
    value::T
    first::Bool
    index::Int
end
EdgeDir(t, dir, start = true) = EdgeDir{eltype(t), dir}(t, start, 0)
function Edge(t::EdgeDir, start, closed)
    result = EdgeDir(t.value, start, 0)
    @assert isclosed(result) == closed
    return result
end
isclosed(x::EdgeDir{:left}) = x.first
isclosed(x::EdgeDir{:right}) = !x.first
startedge(x::AbstractInterval{T,Closed,Open}, i=0) where T = EdgeDir{:left, T}(first(x), true, i)
stopedge(x::AbstractInterval{T,Closed,Open}, i=0) where T = EdgeDir{:left, T}(last(x), false, i)
startedge(x::AbstractInterval{T,Open,Closed}, i=0) where T = EdgeDir{:right, T}(first(x), true, i)
stopedge(x::AbstractInterval{T,Open,Closed}, i=0) where T = EdgeDir{:right, T}(last(x), false, i)

function Interval(x::EdgeDir{D,T}, y::EdgeDir{D,S}) where {D, T, S}
    if D == :left
        return Interval{Union{T,S}, Closed, Open}(x.value, y.value)
    else
        return Interval{Union{T,S}, Open, Closed}(x.value, y.value)
    end
end

# unbunch: represent one or more intervals as a sequence of edges
function unbunch(interval::AbstractInterval)
    return [startedge(interval, 1), stopedge(interval, 1)]
end
unbunch(intervals::AbstractVector{<:Edge}) = intervals
edgetype(::Type{T}) where T = Edge{T}
edgetype(::Type{<:Interval{T, Open, Closed}}) where T = EdgeDir{:right, T}
edgetype(::Type{<:Interval{T, Closed, Open}}) where T = EdgeDir{:left, T}
function unbunch(intervals)
    isempty(intervals) && return edgetype(eltype(intervals))[]
    result = mapreduce(((i) -> [startedge(intervals[i], i), 
                                stopedge(intervals[i], i)]), 
                        vcat, eachindex(intervals))
    return result
end

# represent a sequence of edges as a sequence of one or more intervals
bunch(intervals::AbstractVector{<:AbstractInterval}, orgin, withend) = intervals
intervaltype(::Type{T}) where T = Interval{T}
intervaltype(::EdgeDir{T, :left}) where T = Interval{T, Closed, Open}
intervaltype(::EdgeDir{T, :right}) where T = Interval{T, Open, Closed}
function bunch(edges)
    @assert iseven(length(edges))
    isempty(edges) && return intervaltype(eltype(edges))[]
    return map(Iterators.partition(edges, 2)) do pair
        @assert pair[1].first && !pair[2].first 
        return Interval(pair...)
    end
end

# conditions to check on sequences of edge (handling empty sequence edge cases)
function first_is_less(x, y)
    if isempty(x)
        return false
    elseif isempty(y)
        return true
    else
        return isless(first(x), first(y))
    end
end

function first_is_equal(x, y)
    if isempty(x)
        return false
    elseif isempty(y)
        return false
    else
        return isequal(first(x), first(y))
    end
end

function first_is_closed(x)
    if isempty(x)
        true
    else
        return isclosed(first(x))
    end
end

first_is_start(x) = isempty(x) ? false : isstart(first(x))

#     mergesets(op, x, y)
#
# `mergesets` is the primary internal function implementing set operations (see
# below for its usage). It iterates through the start and stop points in x and
# y, in order from lowest to highest. The implementation is based on the insight
# that we can make a decision to include or exclude points after a given start
# or stop point of the interval (based on `op`), until we hit another start or
# stop point.
#
# For each start/stop point, we determine two things: 
#   1. whether the point should be included in the merge operation or not (based
#        on its membership in both `x` and `y`) by using `op`
#   2. whether the next step will a. define a region that will include this and
#        future points (a start point) b. define a region that will exclude this
#        and future points (a stop point)
#
# Then, we decide to add a new start/stop time point if 1 and 2 match (i.e.
# "should include" points will create a time point when the next point will
# start including points).
#
# A final issue is handling the closed/open nature of each edge. We have to
# track whether to keep the edge (closed) or not (open) separately. Keeping the
# edge may require we keep a singleton edge ([1,1]) such as when to closed edges
# intersect with one another (e.g. (0, 1] ∩ [1, 2))
#
function mergesets(op, x, y)
    result = Union{eltype(x), eltype(y)}[]
    sizehint!(result, length(x) + length(y))

    # to start, points are not included (until we see the starting edge of a set)
    include_future_points = false

    inx = false
    iny = false

    while !(isempty(x) && isempty(y))
        t = first_is_less(x, y) ? first(x) : first(y)
        x_isless = first_is_less(x, y)
        x_equal = first_is_equal(x, y)
        keep_x_edge = inx
        keep_y_edge = iny

        if x_isless || x_equal
            inx = first_is_start(x)
            keep_x_edge = first_is_closed(x)
            x = Iterators.peel(x)[2]
        end
        if !x_isless || x_equal
            iny = first_is_start(y)
            keep_y_edge = first_is_closed(y)
            y = Iterators.peel(y)[2]
        end

        include_t = op(inx, iny)
        keep_edge = op(keep_x_edge, keep_y_edge)
        if include_t != include_future_points
            # start including points
            if !include_future_points
                push!(result, Edge(t, true, keep_edge))
                include_future_points = true
            # if we're about to create an empty interval (e.g. [1, 1)), remove it
            elseif !isempty(result) && !keep_edge && t.value == result[end].value 
                pop!(result)
                include_future_points = false
            # stop including points
            else
                push!(result, Edge(t, false, keep_edge))
                include_future_points = false
            end
        # if we're supposed to keep the edge but we're not including any points
        # right now, we need to add a singleton edge (e.g. [0, 1] ∪ [1, 2])
        elseif keep_edge && !include_future_points
            push!(result, Edge(t.value, true, true))
            push!(result, Edge(t.value, false, true))
        end

    end

    #=@show =#result

    return bunch(result)
end

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

# There is power in a union.
"""
    union(intervals::AbstractVector{<:AbstractInterval})

Flattens a vector of overlapping intervals into a new, smaller vector containing only
non-overlapping intervals.
"""
function Base.union(intervals::AbstractVector{<:AbstractInterval})
    return union!(convert(Vector{AbstractInterval}, intervals))
end
# allow a concretely typed array for `Interval` objects (as opposed to e.g. anchored intervals
# which may change type during the union process)
function Base.union(intervals::AbstractVector{T}) where T <: Interval
    input = convert(Vector{T}, intervals)
    if input === intervals
        input = copy(intervals)
    end
    return union!(input)
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

        # If the current and previous intervals don't meet then move along
        if !overlaps(prev, curr) && !contiguous(prev, curr)
            i = i + 1

        # If the two intervals meet then we absorb the current interval into
        # the previous one.
        else
            intervals[i - 1] = merge(prev, curr)
            deleteat!(intervals, i)
            n -= 1
        end
    end

    return intervals
end

"""
    superset(intervals::AbstractArray{<:AbstractInterval}) -> Interval

Create the smallest single interval which encompasses all of the provided intervals.
"""
function superset(intervals::AbstractArray{<:AbstractInterval})
    left = minimum(LeftEndpoint.(intervals))
    right = maximum(RightEndpoint.(intervals))

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
mergecleanup(x, y) = (sort!(unbunch(union(x))), sort!(unbunch(union(y))))
const AbstractIntervals = Union{AbstractInterval, AbstractVector{<:AbstractInterval}}

function Base.intersect(x::AbstractIntervals, y::AbstractIntervals)
    return mergesets((inx, iny) -> inx && iny, mergecleanup(x, y)...)
end
function Base.union(x::AbstractIntervals, y::AbstractIntervals)
    return mergesets((inx, iny) -> inx || iny, mergecleanup(x, y)...)
end
function Base.setdiff(x::AbstractIntervals, y::AbstractIntervals)
    return mergesets((inx, iny) -> inx && !iny, mergecleanup(x, y)...)
end
function Base.symdiff(x::AbstractIntervals, y::AbstractIntervals)
    return mergesets((inx, iny) -> inx ⊻ iny, mergecleanup(x, y)...)
end
function Base.issubset(x::AbstractIntervals, y::AbstractIntervals)
    return isempty(setdiff(x, y))
end
# may or may not be from based (see top of `Intervals.jl`)
function isdisjoint(x::AbstractIntervals, y::AbstractIntervals)
    return isempty(intersect(x, y))
end
Base.in(x::AbstractInterval, y::AbstractVector{<:AbstractInterval}) = any(yᵢ -> x ∈ yᵢ, y)
function Base.issetequal(x::AbstractIntervals, y::AbstractIntervals)
    x, y = mergecleanup(x,y)
    return x == y
end

asarray(x) = [x]
asarray(x::AbstractArray) = x
alength(x) = 1
alength(x::AbstractArray) = length(x)
"""
    intersectmap(x::Union{AbstractInterval, AbstractVector{<:AbstractInterval}}, 
                 y::Union{AbstractInterval, AbstractVector{<:AbstractInterval}}; sorted=false)

Returns a Vector{Vector{Int}} object where the value at index i gives indices to
all intervals in `y` that intersect with `x[i]`.

"""
function intersectmap(x_::AbstractIntervals, y_::AbstractIntervals)
    x = sort!(unbunch(asarray(x_)))
    y = sort!(unbunch(asarray(y_)))

    result = [Vector{Int}() for _ in 1:alength(x_)]

    active_xs = Set{Int}()
    active_ys = Set{Int}()
    while !isempty(x)
        # println("loop--------------------")
        #=@show =#isempty(x) || first(x)
        #=@show =#isempty(y) || first(y)
        #=@show =#x_less = first_is_less(x, y)
        #=@show =#y_less = first_is_less(y, x)

        if !y_less
            if #=@show =#first_is_start(x) 
                push!(active_xs, first(x).index)
            else
                delete!(active_xs, first(x).index)
            end
            x = Iterators.peel(x)[2]
        end

        if !x_less
            if #=@show =#first_is_start(y) && !x_less
                push!(active_ys, first(y).index)
            else
                delete!(active_ys, first(y).index)
            end
            y = Iterators.peel(y)[2]
        end

        #=@show =#active_ys
        #=@show =#active_xs
        for i in active_xs
            append!(result[i], active_ys)
        end

        #=@show =#result
    end

    return unique!.(result)
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
