
###### Set-related Helpers #####
"""
    IntervalSet{T<:AbstractInterval}

A set of points represented by a sequence of intervals. Set operations over interval sets
return a new IntervalSet, with the fewest number of intervals possible. Unbounded intervals
are not supported. The individual intervals in the set can be accessed by calling
`convert(Array, interval_set)`.

see also: https://en.wikipedia.org/wiki/Interval_arithmetic#Interval_operators

## Examples

```jldoctest; setup = :(using Intervals)
julia> union(IntervalSet(1..5), IntervalSet(3..8))
1-interval IntervalSet{Interval{Int64, Closed, Closed}}:
[1 .. 8]

julia> intersect(IntervalSet(1..5), IntervalSet(3..8))
1-interval IntervalSet{Interval{Int64, Closed, Closed}}:
[3 .. 5]

julia> symdiff(IntervalSet(1..5), IntervalSet(3..8))
2-interval IntervalSet{Interval{Int64, L, R} where {L<:Bound, R<:Bound}}:
[1 .. 3)
(5 .. 8]

julia> union(IntervalSet([1..2, 2..5]), IntervalSet(6..7))
2-interval IntervalSet{Interval{Int64, Closed, Closed}}:
[1 .. 5]
[6 .. 7]

julia> union(IntervalSet([1..5, 8..10]), IntervalSet([4..9, 12..14]))
2-interval IntervalSet{Interval{Int64, Closed, Closed}}:
[1 .. 10]
[12 .. 14]

julia> intersect(IntervalSet([1..5, 8..10]), IntervalSet([4..9, 12..14]))
2-interval IntervalSet{Interval{Int64, Closed, Closed}}:
[4 .. 5]
[8 .. 9]

julia> setdiff(IntervalSet([1..5, 8..10]), IntervalSet([4..9, 12..14]))
2-interval IntervalSet{Interval{Int64, L, R} where {L<:Bound, R<:Bound}}:
[1 .. 4)
(9 .. 10]
```
"""
struct IntervalSet{T <: AbstractInterval}
    items::Vector{T}
end

IntervalSet(interval::T) where T <: AbstractInterval = IntervalSet{T}([interval])
IntervalSet(interval::IntervalSet) = interval
IntervalSet(itr) = IntervalSet{eltype(itr)}(collect(itr))
IntervalSet() = IntervalSet(AbstractInterval[])

Base.copy(intervals::IntervalSet{T}) where {T} = IntervalSet{T}(copy(intervals.items))
Base.eltype(::IntervalSet{T}) where T = T
Base.isempty(intervals::IntervalSet) = isempty(intervals.items) || all(isempty, intervals.items)
Base.:(==)(a::IntervalSet, b::IntervalSet) = issetequal(a, b)
Base.isequal(a::IntervalSet, b::IntervalSet) = isequal(a.items, b.items)
Base.convert(::Type{T}, intervals::IntervalSet) where T <: AbstractArray = convert(T, intervals.items)
function Base.show(io::Base.AbstractPipe, ::MIME"text/plain", x::IntervalSet)
    intervals = union(x)
    n = length(intervals.items)
    iocompact = IOContext(io, :compact => true)
    print(io, "$n-interval ")
    show(io, MIME"text/plain"(), typeof(x))
    println(io, ":")
    nrows = displaysize(io)[1]
    half = fld(nrows, 2) - 2
    if nrows ≥ n && half > 1
        for interval in intervals.items[1:(end-1)]
            show(iocompact, MIME"text/plain"(), interval)
            println(io, "")
        end
        isempty(intervals) || show(iocompact, MIME"text/plain"(), intervals.items[end])
    else
        for interval in intervals.items[1:half]
            show(iocompact, MIME"text/plain"(), interval)
            println(io, "")
        end
        println(io, "⋮")
        for interval in intervals.items[(end-half+1):end-1]
            show(iocompact, MIME"text/plain"(), interval)
            println(io, "")
        end
        show(iocompact, MIME"text/plain"(), intervals.items[end])
    end
end

# currently (to avoid breaking changes) new methods for `Base`
# accept `IntervalSet` objects and Interval singletons.
const AbstractIntervals = Union{AbstractInterval, IntervalSet}

# During merge operations used to compute unions, intersections etc...,
# endpoint types can change (from left to right, and from open to closed,
# etc...). The following structures indicate how endpoints should be tracked.

# TrackEachEndpoint tracks endpoints on a case-by-case basis
# computing closed/open with boolean flags
abstract type EndpointTracking; end
struct TrackEachEndpoint <: EndpointTracking; end
# TrackLeftOpen and TrackRightOpen track the endpoints statically: if the
# intervals to be merged are all left open (or all right open), the resulting
# output will always be all left open (or all right open).
abstract type TrackStatically{T} <: EndpointTracking; end
struct TrackLeftOpen{T} <: TrackStatically{T}; end
struct TrackRightOpen{T} <: TrackStatically{T}; end

function endpoint_tracking(
    ::Type{<:AbstractInterval{T,Open,Closed}},
    ::Type{<:AbstractInterval{U,Open,Closed}},
) where {T,U}
    W = promote_type(T, U)
    return TrackLeftOpen{W}()
end
function endpoint_tracking(
    ::Type{<:AbstractInterval{T,Closed,Open}},
    ::Type{<:AbstractInterval{U,Closed,Open}},
) where {T,U}
    W = promote_type(T, U)
    return TrackRightOpen{W}()
end
function endpoint_tracking(
    ::Type{<:AbstractInterval},
    ::Type{<:AbstractInterval},
)
    return TrackEachEndpoint()
end

endpoint_tracking(a::IntervalSet, b::IntervalSet) = endpoint_tracking(eltype(a), eltype(b))
endpoint_tracking(a::AbstractInterval, b::AbstractInterval) = endpoint_tracking(typeof(a), typeof(b))
endpoint_tracking(a::AbstractVector, b::AbstractVector) = endpoint_tracking(eltype(a), eltype(b))

# track: run a thunk, but only if we are tracking endpoints dynamically
track(fn::Function, ::TrackEachEndpoint, args...) = fn(args...)
track(_, tracking::TrackStatically, args...) = tracking

endpoint_type(::TrackEachEndpoint) = Endpoint
endpoint_type(::TrackLeftOpen{T}) where T = Union{LeftEndpoint{T,Open}, RightEndpoint{T, Closed}}
endpoint_type(::TrackRightOpen{T}) where T = Union{LeftEndpoint{T,Closed}, RightEndpoint{T, Open}}
interval_type(::TrackEachEndpoint) = Interval
interval_type(::TrackLeftOpen{T}) where T = Interval{T, Open, Closed}
interval_type(::TrackRightOpen{T}) where T = Interval{T, Closed, Open}

# `unbunch/bunch`: the generic operation used to implement all set operations operates on a
# series of sorted endpoints (see `mergesets` below); this first requires that
# all vectors of sets be represented by their endpoints. The functions unbunch
# and bunch convert between an interval and an endpoint representation

function unbunch(interval::AbstractInterval, tracking::EndpointTracking; lt=isless)
    return endpoint_type(tracking)[LeftEndpoint(interval), RightEndpoint(interval)]
end
function unbunch(intervals::IntervalSet, tracking::EndpointTracking; kwargs...)
    return unbunch(convert(Vector, intervals), tracking; kwargs...)
end
unbunch_by_fn(_) = identity
function unbunch(
    intervals::Union{
        AbstractVector{<:AbstractInterval},
        Base.Iterators.Enumerate{<:Union{AbstractIntervals, AbstractVector{<:AbstractInterval}}}
    },
    tracking::EndpointTracking;
    lt=isless,
)
    by = unbunch_by_fn(intervals)
    filtered = Iterators.filter(!isempty ∘ by, intervals)
    isempty(filtered) && return endpoint_type(tracking)[]
    result = mapreduce(x -> unbunch(x, tracking), vcat, filtered)
    return sort!(result; lt, by)
end
# support for `unbunch(enumerate(vcat(x)))` (transforming [(i, interval)] -> [(i, endpoint), (i,endpoint)])
unbunch_by_fn(::Base.Iterators.Enumerate) = last
function unbunch((i, interval)::Tuple, tracking; lt=isless)
    eltype = Tuple{Int, endpoint_type(tracking)}
    return eltype[(i, LeftEndpoint(interval)), (i, RightEndpoint(interval))]
end

function unbunch(a::Union{AbstractVector{<:AbstractInterval}, AbstractIntervals},
                 b::Union{AbstractVector{<:AbstractInterval}, AbstractIntervals}; kwargs...)
    tracking = endpoint_tracking(a, b)
    a_ = unbunch(a, tracking; kwargs...)
    b_ = unbunch(b, tracking; kwargs...)
    return a_, b_, tracking
end

# represent a sequence of endpoints as a sequence of one or more intervals
function bunch(endpoints, tracking)
    @assert iseven(length(endpoints))
    isempty(endpoints) && return IntervalSet(interval_type(tracking)[])
    res = map(Iterators.partition(endpoints, 2)) do pair
        return Interval(pair..., tracking)
    end
    return IntervalSet(res)
end
Interval(a::Endpoint, b::Endpoint, ::TrackEachEndpoint) = Interval(a, b)
Interval(a::Endpoint, b::Endpoint, ::TrackLeftOpen{T}) where T = Interval{T,Open,Closed}(a.endpoint, b.endpoint)
Interval(a::Endpoint, b::Endpoint, ::TrackRightOpen{T}) where T = Interval{T,Closed,Open}(a.endpoint, b.endpoint)

# the sentinel endpoint reduces the number of edgecases
# we have to deal with when comparing endpoints during a merge
# NOTE: it's tempting to replace this with an unbounded endpoint
# but if we ever want to support unbounded endpoints in mergesets
# then SentinalEndpoint needs to be greater than those endpointss
struct SentinelEndpoint <: AbstractEndpoint end
function first_endpoint(x)
    isempty(x) && return SentinelEndpoint()
    # if the endpoints are enumerated, eltype will be a tuple
    return eltype(x) <: Tuple ? last(first(x)) : first(x)
end
function last_endpoint(x)
    isempty(x) && return SentinelEndpoint()
    # if the endpoints are enumerated, eltype will be a tuple
    return eltype(x) <: Tuple ? last(last(x)) : last(x)
end


Base.isless(::LeftEndpoint, ::SentinelEndpoint) = true
Base.isless(::RightEndpoint, ::SentinelEndpoint) = true
Base.isless(::SentinelEndpoint, ::LeftEndpoint) = false
Base.isless(::SentinelEndpoint, ::RightEndpoint) = false
Base.isless(::SentinelEndpoint, ::SentinelEndpoint) = false

Base.isequal(::LeftEndpoint, ::SentinelEndpoint) = false
Base.isequal(::RightEndpoint, ::SentinelEndpoint) = false
Base.isequal(::SentinelEndpoint, ::LeftEndpoint) = false
Base.isequal(::SentinelEndpoint, ::RightEndpoint) = false
Base.isequal(::SentinelEndpoint, ::SentinelEndpoint) = true
isclosed(::SentinelEndpoint) = true
isleft(::SentinelEndpoint) = false
isleft(::LeftEndpoint) = true
isleft(::RightEndpoint) = false

#     mergesets(op, x, y)
#
# `mergesets` is the primary internal function implementing set operations (see below for
# its usage). It iterates through the left and right endpoints in x and y, in order from
# lowest to highest. The implementation is based on the insight that we can make a decision
# to include or exclude all points after a given endpoint (based on `op`) and that decision
# will remain unchanged moving left to right along the real-number line until we encounter a
# new endpoint.
#
# For each endpoint, we determine two things:
#   1. whether subsequent points should be included in the merge operation or not (based on
#        its membership in both `x` and `y`) by using `op`
#   2. whether the next step will define a left (start including) or right endpoint (stop
#        includeing)
#
# Then, we decide to add a new endpoint if 1 and 2 match (i.e. "should include" points will
# create a time point when the next point will start including points).
#
# A final issue is handling the closed/open nature of each endpoint. In the general case, we
# have to track whether to keep the endpoint (closed) or not (open) separately. Keeping the
# endpoint may require we keep a singleton endpoint ([1,1]) such as when two closed
# endpoints intersect with one another (e.g. (0, 1] ∩ [1, 2)). In some cases we don't need
# track endpoints at all: e.g. when all endpoints are open right ([1, 0)) or they are all
# open left ((1, 1]) then all resulting endpoints will follow the same pattern.

function mergesets(op, x, y)
    x_, y_, tracking = unbunch(union(x), union(y))
    return mergesets_helper(op, x_, y_, tracking)
end
length_(x::AbstractInterval) = 1
length_(x) = length(x)
function mergesets_helper(op, x, y, endpoint_tracking)
    result = endpoint_type(endpoint_tracking)[]
    sizehint!(result, length_(x) + length_(y))

    # to start, points are not included (until we see the starting endpoint of a set)
    inresult = false
    inx = false
    iny = false

    while !(isempty(x) && isempty(y))
        xᵢ, yᵢ = first_endpoint.((x,y))
        t = xᵢ < yᵢ ? xᵢ : yᵢ

        # whether to include (close) an endpoint
        bound = track(endpoint_tracking) do
            x_closed_end = xᵢ ≤ yᵢ ? isclosed(xᵢ) : inx
            y_closed_end = yᵢ ≤ xᵢ ? isclosed(yᵢ) : iny
            return op(x_closed_end, y_closed_end) ? Closed : Open
        end

        # update endpoints
        if xᵢ ≤ yᵢ
            inx = isleft(xᵢ)
            x = @view(x[2:end])
        end
        if yᵢ ≤ xᵢ
            iny = isleft(yᵢ)
            y = @view(y[2:end])
        end

        # does (new point inclusion) match (current inclusion state)?
        if op(inx, iny) != inresult
            # start including points (left endpoint)
            if !inresult
                endpoint = left_endpoint(t, bound)
                # If we get here, *normally* we want to add a new left (starting)
                # endpoint.
                # EXCEPTION: new endpoint directly abuts old endpoint e.g. [0, 1] ∪ (1, 2]
                if !abuts(last_endpoint(result), endpoint, endpoint_tracking)
                    push!(result, endpoint)
                else
                    pop!(result)
                end
                inresult = true
            else
                # If we get here, *normally* we want to add a right (stopping) end point
                # EXCEPTION: the interval to be created would be empty e.g. [0, 1] ∩ (1, 2]
                if !empty_interval(last_endpoint(result), t, endpoint_tracking)
                    push!(result, right_endpoint(t, bound))
                else
                    pop!(result)
                end
                inresult = false
            end
        else
            track(endpoint_tracking) do
                # edgecase: if we're supposed to close the endpoint but we're not including
                # any points right now, we need to add a singleton endpoint (e.g. [0, 1] ∩
                # [1, 2])
                if bound === Closed && !inresult
                    push!(result, left_endpoint(t, Closed))
                    push!(result, right_endpoint(t, Closed))
                end

                # edgecase: we have an open endpoint right at the edge of two intervals, but we
                # are continuing to include points right now: e.g. symdiff of [0, 1] and [1, 2]
                if bound === Open && inresult && xᵢ == yᵢ
                    push!(result, right_endpoint(t, Open))
                    push!(result, left_endpoint(t, Open))
                end
            end
        end

    end

    return bunch(result, endpoint_tracking)
end
# abuts: true if unioning the two endpoints would lead to a single interval (e.g. (0 1] ∪ (1, 2)))
abuts(::SentinelEndpoint, _, _) = false
abuts(oldstop::Endpoint, newstart, ::TrackStatically) = oldstop.endpoint == newstart.endpoint
function abuts(oldstop::Endpoint, newstart, ::TrackEachEndpoint)
    return oldstop.endpoint == newstart.endpoint && (isclosed(oldstop) || isclosed(newstart))
end

# empty_interval: true if the given left and right endpoints would create an empty interval
empty_interval(::SentinelEndpoint, _, _) = false # sentinal means there was no starting endpoint; there is thus no interval, and so no empty interval
empty_interval(start, stop, ::TrackStatically) = start.endpoint == stop.endpoint
empty_interval(start, stop, ::TrackEachEndpoint) = start > stop
# the below methods create a left or a right endpoint from the endpoint t: note
# that t might not be the same type of endpoint (e.g.
# `left_endpoint(RightEndpoint(...))` is perfectly valid). `mergesets` may
# change which side of an interval an endpoint is on.
left_endpoint(t::Endpoint{T}, ::Type{B}) where {T, B <: Bound} = LeftEndpoint{T, B}(endpoint(t))
right_endpoint(t::Endpoint{T}, ::Type{B}) where {T, B <: Bound} = RightEndpoint{T, B}(endpoint(t))
left_endpoint(t, ::TrackLeftOpen{T}) where T = LeftEndpoint{T,Open}(endpoint(t))
left_endpoint(t, ::TrackRightOpen{T}) where T = LeftEndpoint{T,Closed}(endpoint(t))
right_endpoint(t, ::TrackLeftOpen{T}) where T = RightEndpoint{T,Closed}(endpoint(t))
right_endpoint(t, ::TrackRightOpen{T}) where T = RightEndpoint{T,Open}(endpoint(t))

##### Multi-interval Set Operations #####

# There is power in a union.
"""
    union(intervals::IntervalSets)

Flattens any overlapping intervals within the `IntervalSet` into a new, smaller set
containing only non-overlapping intervals.
"""
Base.union(intervals::IntervalSet{<:Interval}) = union!(copy(intervals))

# In the case where we're dealing with a non-concrete interval type like AnchoredIntervals then simply
# allocate a AbstractInterval vector
function Base.union(intervals::IntervalSet{<:AbstractInterval})
    T = AbstractInterval
    dest = Vector{T}(undef, length(intervals.items))
    copyto!(dest, intervals.items)
    return union!(IntervalSet{T}(dest))
end

"""
    union!(intervals::IntervalSet)

Flattens a vector of overlapping intervals in-place to be a smaller vector containing only
non-overlapping intervals.
"""
function Base.union!(intervals::IntervalSet)
    items = intervals.items
    sort!(items)

    i = 2
    n = length(items)
    while i <= n
        prev = items[i - 1]
        curr = items[i]

        # If the current and previous intervals don't meet then move along
        if !overlaps(prev, curr) && !contiguous(prev, curr)
            i = i + 1

        # If the two intervals meet then we absorb the current interval into
        # the previous one.
        else
            items[i - 1] = merge(prev, curr)
            deleteat!(items, i)
            n -= 1
        end
    end

    return intervals
end

"""
    superset(intervals::IntervalSet) -> Interval

Create the smallest single interval which encompasses all of the provided intervals.
"""
function superset(intervals::IntervalSet)
    left = minimum(LeftEndpoint.(intervals.items))
    right = maximum(RightEndpoint.(intervals.items))

    return Interval(left, right)
end


# set operations over multi-interval sets
Base.intersect(x::IntervalSet, y::IntervalSet) = mergesets((inx, iny) -> inx && iny, x, y)
Base.union(x::IntervalSet, y::IntervalSet) = mergesets((inx, iny) -> inx || iny, x, y)
Base.setdiff(x::IntervalSet, y::IntervalSet) = mergesets((inx, iny) -> inx && !iny, x, y)
Base.symdiff(x::IntervalSet, y::IntervalSet) = mergesets((inx, iny) -> inx ⊻ iny, x, y)
Base.isdisjoint(x::AbstractIntervals, y::AbstractIntervals) = isempty(intersect(x, y))

Base.issubset(x, y::IntervalSet) = x in y
Base.issubset(x::AbstractInterval, y::IntervalSet) = any(Base.Fix1(issubset, x), y.items)
Base.issubset(x::IntervalSet, y::AbstractInterval) = all(Base.Fix2(issubset, y), x.items)
Base.issubset(x::IntervalSet, y::IntervalSet) = isempty(setdiff(x, y))

# Add methods where just 1 argument is an Interval
for f in (:intersect, :union, :setdiff, :symdiff)
    @eval Base.$f(x::AbstractInterval, y::IntervalSet) = $f(IntervalSet([x]), y)
    @eval Base.$f(x::IntervalSet, y::AbstractInterval) = $f(x, IntervalSet([y]))
end

function Base.issetequal(x::AbstractIntervals, y::AbstractIntervals)
    x, y, tracking = unbunch(union(IntervalSet(x)), union(IntervalSet(y)))
    return x == y || isempty(bunch(x, tracking)) && isempty(bunch(y, tracking))
end

# when `x` is number-like object (Number, Date, Time, etc...):
Base.in(x, y::IntervalSet) = any(Base.Fix1(in, x), y.items)

# order edges so that closed boundaries are on the outside: e.g. [( )]
intersection_order(x::Endpoint) = isleft(x) ? !isclosed(x) : isclosed(x)
intersection_isless_fn(::TrackStatically) = isless
function intersection_isless_fn(::TrackEachEndpoint)
    function (x,y)
        if isequal(x, y)
            return isless(intersection_order(x), intersection_order(y))
        else
            return isless(x, y)
        end
    end
end

"""
    find_intersections(
        x::AbstractVector{<:AbstractInterval},
        y::AbstractVector{<:AbstractInterval}
    )

Returns a `Vector{Vector{Int}}` where the value at index `i` gives the indices to all
intervals in `y` that intersect with `x[i]`.
"""
find_intersections(x, y) = find_intersections(vcat(x), vcat(y))
function find_intersections(x::AbstractVector{<:AbstractInterval}, y::AbstractVector{<:AbstractInterval})
    tracking = endpoint_tracking(x, y)
    lt = intersection_isless_fn(tracking)
    x_endpoints = unbunch(enumerate(x), tracking; lt)
    y_endpoints = unbunch(enumerate(y), tracking; lt)
    result = [Vector{Int}() for _ in 1:length(x)]

    return find_intersections_helper!(result, x_endpoints, y_endpoints, lt)
end

function find_intersections_helper!(result, x, y, lt)
    active_xs = Set{Int}()
    active_ys = Set{Int}()
    while !isempty(x)
        xᵢ, yᵢ = first_endpoint(x), first_endpoint(y)
        x_less = lt(xᵢ, yᵢ)
        y_less = lt(yᵢ, xᵢ)

        if !y_less
            if isleft(xᵢ)
                push!(active_xs, first(first(x)))
            else
                delete!(active_xs, first(first(x)))
            end
            x = @view x[2:end]
        end

        if !x_less
            if isleft(yᵢ)
                push!(active_ys, first(first(y)))
            else
                delete!(active_ys, first(first(y)))
            end
            y = @view y[2:end]
        end

        for i in active_xs
            append!(result[i], active_ys)
        end
    end

    return unique!.(result)
end

function find_intersections(
    x::AbstractVector{<:AbstractInterval{T1,Closed,Closed}},
    y::AbstractVector{<:AbstractInterval{T2,Closed,Closed}},
) where {T1,T2}
    # Strategy:
    # two binary searches per interval `I` in `x`
    # * identify the set of intervals in `y` that start during-or-after `I`
    # * identify the set of intervals in `y` that stop before-or-during `I`
    # * intersect them
    starts = first.(y)
    starts_perm = sortperm(starts)
    starts_sorted = starts[starts_perm]

    # Sneaky performance optimization (makes a huge difference!)
    # Rather than sorting `stops` relative to `y`, we sort it relative to `starts`.
    # This allows us to work in the `starts` frame of reference until the very end.
    # In particular, when we intersect the sets of intervals obtained from starts and from stops,
    # the `starts` set can be kept as a `UnitRange`, making the intersection *much* faster.
    stops = last.(y[starts_perm])
    stops_perm = sortperm(stops)
    stops_sorted = stops[stops_perm]
    len = length(stops_sorted)

    results = Vector{Vector{Int}}(undef, length(x))
    for (i, I) in enumerate(x)
        # find all the starts which occur before the end of `I`
        idx_first = searchsortedlast(starts_sorted, last(I))
        if idx_first < 1
            results[i] = Int[]
            continue
        end

        # find all the stops which occur after the start of `I`
        idx_last = searchsortedfirst(stops_sorted, first(I))

        if idx_last > len
            results[i] = Int[]
            continue
        end

        # Working in "starts" frame of reference
        starts_before_or_during = 1:idx_first
        stops_during_or_after = @views stops_perm[idx_last:end]

        # Intersect them
        r = intersect(starts_before_or_during, stops_during_or_after)

        # *Now* go back to y's sorting order, post-intersection.
        results[i] = starts_perm[r]
    end
    return results
end
