
###### Set-related Helpers #####
"""
    IntervalSet{T<:AbstractInterval}

A set of points represented by a sequence of intervals. Set operations over interval sets
return a new IntervalSet, with the fewest number of intervals possible. Unbounded intervals
are not supported. The individual intervals in the set can be accessed using the iteration
API or by passing the set to `Array`.

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
abstract type AbstractEndpointTracking{T}; end
struct TrackEachEndpoint{T, F} <: AbstractEndpointTracking{T}
    factory::F
end

# TrackLeftOpen and TrackRightOpen track the endpoints statically: if the
# intervals to be merged are all left open (or all right open), the resulting
# output will always be all left open (or all right open).
abstract type AbstractTrackStatically{T} <: AbstractEndpointTracking{T}; end
struct TrackLeftOpen{T, F} <: AbstractTrackStatically{T}
    factory::F
end
struct TrackRightOpen{T, F} <: AbstractTrackStatically{T}
    factory::F
end

function endpoint_tracking(
    ::Type{<:AbstractInterval{T,Open,Closed}},
    ::Type{<:AbstractInterval{U,Open,Closed}},
    factory
) where {T,U}
    W = promote_type(T, U)
    return TrackLeftOpen{W}(factory)
end
function endpoint_tracking(
    ::Type{<:AbstractInterval{T,Closed,Open}},
    ::Type{<:AbstractInterval{U,Closed,Open}},
    factory
) where {T,U}
    W = promote_type(T, U)
    return TrackRightOpen{W}(factory)
end
function endpoint_tracking(
    ::Type{<:AbstractInterval{T}},
    ::Type{<:AbstractInterval{U}},
    factory
)
    W = promote_type(T, U)
    return TrackEachEndpoint{W}(factory)
end
function endpoint_tracking(
    ::Type{<:AbstractInterval},
    ::Type{<:AbstractInterval},
    factory
)
    return TrackEachEndpoint{Any}(factory)
end

endpoint_tracking(a::IntervalSet, b::IntervalSet) = endpoint_tracking(eltype(a), eltype(b), interval_factory(a, b))
endpoint_tracking(a::AbstractInterval, b::AbstractInterval) = endpoint_tracking(typeof(a), typeof(b), interval_factory(a, b))
endpoint_tracking(a::AbstractVector, b::AbstractVector) = endpoint_tracking(eltype(a), eltype(b), interval_factory(a, b))

# When we split intervals into endpoints we also need a way to construct new intervals from
# the split endpoints. This is done using an factory. The default one just calls `Interval`
# on the endpoints. These is some additional tracking of types that needs to be handled to
# indicate the proper eltype for arrays of the constructed intervals. The methods are setup
# to minimize the number of methods that need to be overloaded to define a new type of
# factory (for a differnet concrete interval type).
struct AbstractFacotry; end
struct DefaultFactory{T,D} <: AbstractFactory; end
(tr::AbstractEndpointTracking)(a, b) = tr.factory(a, b)
(::DefaultFactory{T})(a::AbstractEndpoint, b::AbstractEndpoint) where T = Interval{T}(a, b)
(::DefaultFactory{T})() where T = Interval{T,Closed,Open}(zero(T), zero(T))
(::DefaultFactory{T,:LeftOpen})() where T = Interval{T,Open,Closed}(zero(T), zero(T))
interval_factory(a::AbstractInterval{T}) = DefaultFactory{T, :RightOpen}()
interval_factory(a::AbstractInterval{T,Open,Closed}) = DefaultFactory{T, :LeftOpen}()
interval_factory(a::IntervalSet, b::IntervalSet) = interval_factory(a.items, b.items)
interval_factory(x::AbstractInterval{T}, y::AbstractInterval{U}) where {T,U} = DefaultFactory{promote_type{T, U}, :RightOpen}()
interval_factory(x::AbstractInterval{T,Open,Closed}, y::AbstractInterval{U,Open,Closed}) where {T,U} = DefaultFactory{promote_type{T, U}, :LeftOpen}()
interval_factory(x::AbstractInterval, y::AbstractInterval) = DefaultFactory{Any, :RightOpen}()
interval_type(x, L, R) = interval_type(x)
interval_type(::DefaultFactory{T}) where {T} = Interval{T}
interval_type(::DefaultFactory{T}, L, R) where {T} = Interval{T,L,R}
LeftEndpoint(interval::AbstractInterval, tr::AbstractEndpointTracking) = LeftEndpoint(interval, tr.factory)
RightEndpoint(interval::AbstractInterval, tr::AbstractEndpointTracking) = RightEndpoint(interval, tr.factory)

# track: run a thunk, but only if we are tracking endpoints dynamically
track(fn::Function, ::TrackEachEndpoint, args...) = fn(args...)
track(_, tracking::AbstractTrackStatically, args...) = tracking

function endpoint_type(::AbstractInterval{T,L,R}) where {T,L,R} 
    return Union{LeftEndpoint{T,L}, RightEndpoint{T,R}}
end
# if eltype is not concrete give an abstract endpoint type; note that if we were to dispatch
# on AbstractVector{<:AbstractInterval} here would enforce a concrete eltype
function endpoint_type(x::AbstractVector)
    eltype(x) isa AbstractInterval || error("Expected vector of intervals")
    return Endpoint
end
# if eltype is concrete, give a union of concrete endpoint types
function endpoint_type(::AbstractVector{I}) where {T,L,R,I <: AbstractInterval{T,L,R}}
    return Union{LeftEndpoint{T,L}, RightEndpoint{T,R}}
end
endpoint_type(::TrackEachEndpoint{T}) where T = Endpoint{T}
endpoint_type(::TrackLeftOpen{T}) where T = Union{LeftEndpoint{T,Open}, RightEndpoint{T, Closed}}
endpoint_type(::TrackRightOpen{T}) where T = Union{LeftEndpoint{T,Closed}, RightEndpoint{T, Open}}
interval_type(track::TrackEachEndpoint) = interval_type(track.factory)
interval_type(track::TrackRightOpen{T}) where {T} = interval_type(track.factory, Closed, Open)
interval_type(track::TrackLeftOpen{T}) where {T} = interval_type(track.factory, Open, Closed)

# `unbunch/bunch`: the generic operation used to implement all set operations operates on a
# series of sorted endpoints (see `mergesets` below); this first requires that
# all vectors of sets be represented by their endpoints. The functions unbunch
# and bunch convert between an interval and an endpoint representation

function unbunch(interval::AbstractInterval, tracking::AbstractEndpointTracking; lt=isless)
    return endpoint_type(interval)[LeftEndpoint(interval, tracking), 
                                   RightEndpoint(interval, tracking)]
end
function unbunch(intervals::IntervalSet, tracking::AbstractEndpointTracking; kwargs...)
    return unbunch(convert(Vector, intervals), tracking; kwargs...)
end
unbunch_by_fn(_) = identity
function unbunch(
    intervals::Union{
        AbstractVector{<:AbstractInterval},
        Base.Iterators.Enumerate{<:Union{AbstractIntervals, AbstractVector{<:AbstractInterval}}}
    },
    tracking::AbstractEndpointTracking;
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
    return eltype[(i, LeftEndpoint(interval, tracking)), 
                  (i, RightEndpoint(interval, tracking))]
end

function unbunch(a::Union{AbstractVector{<:AbstractInterval}, AbstractIntervals},
                 b::Union{AbstractVector{<:AbstractInterval}, AbstractIntervals}; kwargs...)
    tracking = endpoint_tracking(a, b)
    a_ = unbunch(a, tracking; kwargs...)
    b_ = unbunch(b, tracking; kwargs...)
    return a_, b_, tracking
end

# represent a sequence of endpoints as a sequence of one or more intervals
function bunch(endpoints::AbstractVector, tracking)
    @assert iseven(length(endpoints))
    isempty(endpoints) && return IntervalSet(interval_type(tracking)[])
    res = map(x -> tracking(x...), Iterators.partition(endpoints, 2))
    return IntervalSet(res)
end

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
    x, y = union(x), union(y)
    tracking = endpoint_tracking(x, y)
    x_, y_, tracking = unbunch(x, y)
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
abuts(oldstop::Endpoint, newstart, ::AbstractTrackStatically) = endpoint(oldstop) == endpoint(newstart)
function abuts(oldstop::Endpoint, newstart, ::AbstractTrackDynamically)
    return endpoint(oldstop) == endpoint(newstart) && (isclosed(oldstop) || isclosed(newstart))
end

# empty_interval: true if the given left and right endpoints would create an empty interval
empty_interval(::SentinelEndpoint, _, _) = false # sentinal means there was no starting endpoint; there is thus no interval, and so no empty interval
empty_interval(start, stop, ::AbstractTrackStatically) = endpoint(start) == endpoint(stop)
empty_interval(start, stop, ::AbstractTrackDynamically) = start > stop
# the below methods create a left or a right endpoint from the endpoint t: note
# that t might not be the same type of endpoint (e.g.
# `LeftEndpoint(RightEndpoint(...), tracking)` is perfectly valid). `mergesets` may
# change which side of an interval an endpoint is on.
left_endpoint(t::Endpoint{T}, ::Type{B}) where {T, B <: Bound} = LeftEndpoint{T, B}(endpoint(t))
right_endpoint(t::Endpoint{T}, ::Type{B}) where {T, B <: Bound} = RightEndpoint{T, B}(endpoint(t))
left_endpoint(t::Endpoint, ::TrackLeftOpen{T}) where T = LeftEndpoint{T,Open}(endpoint(t))
left_endpoint(t::Endpoint, ::TrackRightOpen{T}) where T = LeftEndpoint{T,Closed}(endpoint(t))
right_endpoint(t::Endpoint, ::TrackLeftOpen{T}) where T = RightEndpoint{T,Closed}(endpoint(t))
right_endpoint(t::Endpoint, ::TrackRightOpen{T}) where T = RightEndpoint{T,Open}(endpoint(t))

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
intersection_isless_fn(::AbstractTrackStatically) = isless
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
