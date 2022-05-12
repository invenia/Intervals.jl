
###### Set-related Helpers #####

# most set-related methods can operate over both individual intervals and
# vectors of intervals
# we need both of the types here because most methods need `AbstractIntervals`: that
# allows for e.g. an AbstractVector{AbstractInterval} type to match a method, whereas
# `AbstractIntervalsOf` could not match this type because the type parameters imply a concrete
# type for T, L and R.
const AbstractIntervalsOf{T,L,R} = Union{AbstractInterval{T,L,R}, AbstractVector{<:AbstractInterval{T,L,R}}}
const AbstractIntervals = Union{AbstractInterval, AbstractVector{<:AbstractInterval}}

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
    ::AbstractIntervalsOf{T,Open,Closed},
    ::AbstractIntervalsOf{U,Open,Closed},
) where {T,U}
    W = promote_type(T, U)
    return TrackLeftOpen{W}()
end
function endpoint_tracking(
    ::AbstractIntervalsOf{T,Closed,Open},
    ::AbstractIntervalsOf{U,Closed,Open},
) where {T,U}
    W = promote_type(T, U)
    return TrackRightOpen{W}()
end
endpoint_tracking(a, b) = TrackEachEndpoint()

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
unbunch_by_fn(_) = identity
function unbunch(intervals::Union{AbstractIntervals, Base.Iterators.Enumerate{<:AbstractIntervals}}, 
                 tracking::EndpointTracking; lt=isless)
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

function unbunch(a::AbstractIntervals, b::AbstractIntervals; kwds...)
    tracking = endpoint_tracking(a, b)
    a_ = unbunch(a, tracking; kwds...)
    b_ = unbunch(b, tracking; kwds...)
    return a_, b_, tracking
end

# represent a sequence of endpoints as a sequence of one or more intervals
function bunch(endpoints, tracking)
    @assert iseven(length(endpoints))
    isempty(endpoints) && return interval_type(tracking)[]
    return map(Iterators.partition(endpoints, 2)) do pair
        return Interval(pair..., tracking)
    end
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
# `mergesets` is the primary internal function implementing set operations (see
# below for its usage). It iterates through the left and right endpoints in x
# and y, in order from lowest to highest. The implementation is based on the
# insight that we can make a decision to include or exclude all points after a
# given endpoint (based on `op`) and that decision will remain unchanged moving
# left to right along the real-number line until we encounter a new endpoint.
#
# For each endpoint, we determine two things: 
#   1. whether subsequent points should be included in the merge operation or
#        not (based on its membership in both `x` and `y`) by using `op`
#   2. whether the next step will define a left (start including) or right
#        endpoint (stop includeing)
#
# Then, we decide to add a new endpoint if 1 and 2 match (i.e. "should include"
# points will create a time point when the next point will start including
# points).
#
# A final issue is handling the closed/open nature of each endpoint. In the
# general case, we have to track whether to keep the endpoint (closed) or not
# (open) separately. Keeping the endpoint may require we keep a singleton
# endpoint ([1,1]) such as when to closed endpoints intersect with one another
# (e.g. (0, 1] ∩ [1, 2)). In some cases we don't need track endpoints at all:
# e.g. when all endpoints are open right ([1, 0)) or they are all open left ((1, 1])
# then all resulting endpoints will follow the same pattern.

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
                push!(result, left_endpoint(t, bound))
                inresult = true
            # stop including points (right endpoint), as long as the result will be non-empty
            elseif !empty_interval(last_endpoint(result), t, endpoint_tracking)
                push!(result, right_endpoint(t, bound))
                inresult = false
            # the interval is empty: remove the previously added endpoint 
            else
                pop!(result)
                inresult = false
            end
        # edgecase: if we're supposed to close the endpoint but we're not including
        # any points right now, we need to add a singleton endpoint (e.g. [0, 1] ∩
        # [1, 2])
        else
            track(endpoint_tracking) do
                if bound === Closed && !inresult
                    push!(result, left_endpoint(t, Closed))
                    push!(result, right_endpoint(t, Closed))
                end
            end
        end

    end

    return bunch(result, endpoint_tracking)
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

set_docstring(op, return_array=true) = """
    $op(x::Union{AbstractVector{<:AbstractInterval}, AbstractInterval}, 
        y::Union{AbstractVector{<:AbstractInterval}), AbstractInterval})

You can use `$op` over two pairs of interval vectors. It interprets `x` and `y` as
representing a set covered by the provided intervals. 

$(!return_array ? "" : """
The return value is an array of non-overlapping intervals representing the $op over these 
sets. If both arguments are single intervlas, the return value is always a single interval 
(or an error if that's not possible). If you want to allow for multiple interval return 
values for single intervals `a` and `b` you can call `$op([a], [b])`.
    
""")A limitation of $op is that it only supports intervals that are bounded.
"""

# set operations over multi-interval sets
"""
$(set_docstring("intersect"))
"""
Base.intersect(x::AbstractIntervals, y::AbstractIntervals) = mergesets((inx, iny) -> inx && iny, x, y)

"""
$(set_docstring("union"))
"""
Base.union(x::AbstractIntervals, y::AbstractIntervals) = mergesets((inx, iny) -> inx || iny, x, y)

"""
$(set_docstring("setdiff"))
"""
Base.setdiff(x::AbstractIntervals, y::AbstractIntervals) = mergesets((inx, iny) -> inx && !iny, x, y)

"""
$(set_docstring("symdiff"))
"""
Base.symdiff(x::AbstractIntervals, y::AbstractIntervals) = mergesets((inx, iny) -> inx ⊻ iny, x, y)

"""
$(set_docstring("issubset", false))
"""
Base.issubset(x::AbstractIntervals, y::AbstractIntervals) = isempty(setdiff(x, y))
# may or may not be from Base (see top of `Intervals.jl`)

"""
$(set_docstring("isdisjoint", false))
"""
Base.isdisjoint(x::AbstractIntervals, y::AbstractIntervals) = isempty(intersect(x, y))

Base.in(x, y::AbstractVector{<:AbstractInterval}) = any(yᵢ -> x ∈ yᵢ, y)
function Base.issetequal(x::AbstractIntervals, y::AbstractIntervals)
    x, y, tracking = unbunch(union(x), union(y))
    return x == y || (all(isempty, bunch(x, tracking)) && all(isempty, bunch(y, tracking)))
end

# order edges so that closed boundaries are on the outside: e.g. [( )]
intersection_order(x::Endpoint) = isleft(x) ? !isclosed(x) : isclosed(x)
intersection_isless_fn(::TrackStatically) = isless
function intersection_isless_fn(::TrackEachEndpoint) 
    function(x,y)
        if isequal(x, y)
            return isless(intersection_order(x), intersection_order(y))
        else
            return isless(x, y)
        end
    end
end

"""
    find_intersections(x::Union{AbstractInterval, AbstractVector{<:AbstractInterval}}, 
                       y::Union{AbstractInterval, AbstractVector{<:AbstractInterval}})

Returns a Vector{Vector{Int}} where the value at index i gives the indices to
all intervals in `y` that intersect with `x[i]`. 

"""
function find_intersections(x_::AbstractIntervals, y_::AbstractIntervals)
    xa, ya = vcat(x_), vcat(y_)
    tracking = endpoint_tracking(xa, ya)
    lt = intersection_isless_fn(tracking)
    x = unbunch(enumerate(xa), tracking; lt)
    y = unbunch(enumerate(ya), tracking; lt)
    result = [Vector{Int}() for _ in 1:length(xa)]

    return find_intersections_helper!(result, x, y, lt)
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

