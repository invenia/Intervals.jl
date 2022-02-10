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

### Note on Ordering

The `Interval` constructor will compare `first` and `last`; if it finds that
`first > last`, they will be reversed to ensure that `first < last`. This
simplifies calls to `in` and `intersect`:

```julia
julia> i = Interval{Open,Closed}(Date(2016, 8, 11), Date(2013, 2, 13))
Interval{Date,Closed,Open}(2013-02-13, 2016-08-11)
```

Note that the bounds are also reversed in this case.

### Multi-interval set operations

Set operations can also be performed over two pairs of interval arrays. These set operations
take the form of `op(x::Vector{<:Interval}, y::Vector{<:Interval})` and intrepret `x` and 
`y` as representing a set covered by the provided intervals. The return value is an array of
non-overlaping intervals representing the result of `op` over these sets. You can also pass 
a single interval to either arugment (e.g. op(x::Interval, y::Vector{<:Interval})).

These multi-interval set operations currently only support intervals that are
bounded.

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

# most set-related methods can operate over both individual intervals and
# vectors of intervals
const AbstractIntervals = Union{AbstractInterval, AbstractVector{<:AbstractInterval}}

# During merge operations used to compute unions, intersections etc...,
# endpoint types can change (from left to right, and from open to closed,
# etc...). The following structures indicate how endpoints should be tracked.

# TrackEachEndpoint tracks endpoints dynamically using a boolean flag that
# depends on the closed or open nature of the endpoints to be merged.
abstract type EndpointTracking; end
struct TrackEachEndpoint <: EndpointTracking; end
# TrackLeftOpen and TrackRightOpen track the endpoints statically: if the
# intervals to be merged are all left open (or all right open), the resulting
# output will always be all left open (or all right open).
abstract type TrackStatically{T} <: EndpointTracking; end
struct TrackLeftOpen{T} <: TrackStatically{T}; end
struct TrackRightOpen{T} <: TrackStatically{T}; end

function endpoint_tracking(
    ::AbstractVector{<:AbstractInterval{T,Open,Closed}},
    ::AbstractVector{<:AbstractInterval{U,Open,Closed}},
) where {T,U}
    W = promote_type(T, U)
    return TrackLeftOpen{W}()
end
function endpoint_tracking(
    ::AbstractVector{<:AbstractInterval{T,Closed,Open}},
    ::AbstractVector{<:AbstractInterval{U,Closed,Open}},
) where {T,U}
    W = promote_type(T, U)
    return TrackRightOpen{W}()
end
endpoint_tracking(a, b) = TrackEachEndpoint()

# track: register the open closed nature of a new endpoint or track an existing flag
track(x::Endpoint, ::TrackEachEndpoint) = isclosed(x)
track(x::Bool, ::TrackEachEndpoint) = x
# but only if required
track(_, ::TrackStatically) = nothing
# combine tracked endpoints into a final descion for a new endpoint
# using the appropriate boolean operator (e.g. || for union, && for intersection)
endpoint_closure(op, x, y, ::TrackEachEndpoint) = op(x,y)
# alaternatively, just note the static type used to determine all endpoints
endpoint_closure(op, x, y, tracking::TrackStatically) = tracking
# track_closure: indicates if a boolean flag is used to track closures
track_closures(::TrackEachEndpoint) = true
track_closures(::TrackStatically) = false

# simple endpoints are used for `TrackStatically`, when we don't want to keep
# track of the open/closed nature of intervals. Without SimpleEndpoint the
# return value for mergetypes would always be an array of abstract types; this
# allows the result to be type stable when possible
struct SimpleEndpoint{T}
    left::Bool
    val::T
end
endpoint(x::SimpleEndpoint) = x.val
isleft(x::SimpleEndpoint) = x.left
Base.isless(x::SimpleEndpoint, y::SimpleEndpoint) = isless(x.val, y.val)
Base.:(==)(x::SimpleEndpoint, y::SimpleEndpoint) = x.val == y.val

endpoint_types(::TrackEachEndpoint) = Endpoint
endpoint_types(::TrackStatically{T}) where T = SimpleEndpoint{T} # see just below

# `unbunch/bunch`: the generic operation used to implement all set operations operates on a
# series of sorted endpoints (see `mergesets` below); this first requires that
# all vectors of sets be represented by their endpoints. The functions unbunch
# and bunch convert between an interval and an endpoint representation

# when tracking endpoints dynamically we return a different type for left and right
function unbunch_helper(interval, enumerate, i, ::TrackEachEndpoint)
    if enumerate
        return [(i, LeftEndpoint(interval)), (i, RightEndpoint(interval))]
    else
        return [LeftEndpoint(interval), RightEndpoint(interval)]
    end
end

# when statically tracking endpoints we ignore the closed/open nature of each
# endpoint using `SimpleEndpoint`
function unbunch_helper(interval, enumerate, i, ::TrackStatically)
    if enumerate
        return [(i, SimpleEndpoint(true, first(interval))), (i, SimpleEndpoint(false, last(interval)))]
    else
        return [SimpleEndpoint(true, first(interval)), SimpleEndpoint(false, last(interval))]
    end
end

function unbunch(interval::AbstractInterval, tracking::EndpointTracking; enumerate=false, lt=isless) where T
    return unbunch_helper(interval, enumerate, 1, tracking)
end
function unbunch(intervals::AbstractIntervals, tracking::EndpointTracking; enumerate=false, lt=isless)
    filtered = filter(i -> !isempty(intervals[i]), eachindex(intervals))
    isempty(filtered) && return Union{}[]
    result = mapreduce(vcat, filtered) do i
        return unbunch_helper(intervals[i], enumerate, i, tracking)
    end
    return sort!(result; lt, by=enumerate ? last : identity)
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
    isempty(endpoints) && return Union{}[]
    return map(Iterators.partition(endpoints, 2)) do pair
        return Interval(pair..., tracking)
    end
end
Interval(a, b, ::TrackEachEndpoint) = Interval(a, b)
Interval(a, b, ::TrackLeftOpen{T}) where T = Interval{T,Open,Closed}(a.val, b.val)
Interval(a, b, ::TrackRightOpen{T}) where T = Interval{T,Closed,Open}(a.val, b.val)

# the sentinel endpoint reduces the number of edgecases 
# we have to deal with when comparing endpoints during a merge
struct SentinelEndpoint; end
function first_endpoint(x)
    isempty(x) && return SentinelEndpoint()
    return eltype(x) <: Tuple ? last(first(x)) : first(x)
end
function last_endpoint(x)
    isempty(x) && return SentinelEndpoint() 
    return eltype(x) <: Tuple ? last(last(x)) : last(x)
end

Base.isless(::SimpleEndpoint, ::SentinelEndpoint) = true
Base.isless(::SentinelEndpoint, ::SimpleEndpoint) = false

Base.isless(::LeftEndpoint, ::SentinelEndpoint) = true
Base.isless(::RightEndpoint, ::SentinelEndpoint) = true
Base.isless(::SentinelEndpoint, ::LeftEndpoint) = false
Base.isless(::SentinelEndpoint, ::RightEndpoint) = false

Base.isless(::SentinelEndpoint, ::SentinelEndpoint) = false

Base.isequal(::SimpleEndpoint, ::SentinelEndpoint) = false
Base.isequal(::LeftEndpoint, ::SentinelEndpoint) = false
Base.isequal(::RightEndpoint, ::SentinelEndpoint) = false
Base.isequal(::SentinelEndpoint, ::SimpleEndpoint) = false
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
    return mergesets_helper(op, x_, y_, endpoint_tracking(x, y))
end
function mergesets_helper(op, x, y, endpoint_tracking)
    result = endpoint_types(endpoint_tracking)[]
    sizehint!(result, length(x) + length(y))

    # to start, points are not included (until we see the starting endpoint of a set)
    inresult = false
    inx = false
    iny = false

    while !(isempty(x) && isempty(y))
        xᵢ = first_endpoint(x)
        yᵢ = first_endpoint(y)
        t = xᵢ < yᵢ ? xᵢ : yᵢ
        x_closed_endpoint, y_closed_endpoint = track.((inx, iny), Ref(endpoint_tracking))

        if xᵢ ≤ yᵢ
            inx = isleft(xᵢ)
            x_closed_endpoint = track(xᵢ, endpoint_tracking)
            x = @view(x[2:end])
        end
        if yᵢ ≤ xᵢ
            iny = isleft(yᵢ)
            y_closed_endpoint = track(yᵢ, endpoint_tracking)
            y = @view(y[2:end])
        end

        close_endpoint = endpoint_closure(op, x_closed_endpoint, y_closed_endpoint, endpoint_tracking)
        if (op(inx, iny)) != (inresult)
            # start including points
            if !inresult
                push!(result, left_endpoint(t, close_endpoint))
                inresult = true
            # edgecase: if `inresult == true` we want to add a right endpoint
            # (what `else` does below); *but* if this would create an empty
            # interval (e.g. (1, ), [1, 1) or (1, 1]), we need to instead remove the
            # most recent left endpoint
            elseif empty_interval(last_endpoint(result), t, endpoint_tracking)
                pop!(result)
                inresult = false
            # stop including points
            else
                push!(result, right_endpoint(t, close_endpoint))
                inresult = false
            end
        # edgecase: if we're supposed to close the endpoint but we're not including
        # any points right now, we need to add a singleton endpoint (e.g. [0, 1] ∩
        # [1, 2])
        elseif track_closures(endpoint_tracking) && close_endpoint && !inresult
            push!(result, left_endpoint(t, true))
            push!(result, right_endpoint(t, true))
        end

    end

    return bunch(result, endpoint_tracking)
end
# empty_interval: true if the left and right endpoints would create an empty interval
empty_interval(::SentinelEndpoint, stop, _) = false # sentinal means there was no starting endpoint; there is thus no interval, and so no empty interval
function empty_interval(start, stop, ::TrackStatically)
    return endpoint(start) == endpoint(stop)
end
function empty_interval(start, stop, ::TrackEachEndpoint)
    endpoint(start) == endpoint(stop) && any(!isclosed, (start, stop))
end
# the below methods create a left or a right endpoint from the endpoint t: note
# that t might not be the same type of endpoint (e.g.
# `left_endpoint(RightEndpoint(...))` is perfectly valid). `mergesets` may
# change which side of an interval an endpoint is on.
left_endpoint(t::Endpoint{T}, closed::Bool) where T = LeftEndpoint{T,closed ? Closed : Open}(endpoint(t))
right_endpoint(t::Endpoint{T}, closed::Bool) where T = RightEndpoint{T,closed ? Closed : Open}(endpoint(t))
left_endpoint(t::SimpleEndpoint{T}, _) where T = SimpleEndpoint(true, t.val)
right_endpoint(t::SimpleEndpoint{T}, _) where T = SimpleEndpoint(false, t.val)

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

function Base.merge(a::AbstractInterval, b::AbstractInterval)
    if !overlaps(a, b) && !contiguous(a, b)
        throw(ArgumentError("$a and $b are neither overlapping or contiguous."))
    end

    left = min(LeftEndpoint(a), LeftEndpoint(b))
    right = max(RightEndpoint(a), RightEndpoint(b))
    return Interval(left, right)
end

Base.union(x::AbstractInterval) = x

Base.intersect(x::AbstractIntervals, y::AbstractIntervals) = mergesets((inx, iny) -> inx && iny, x, y)
Base.union(x::AbstractIntervals, y::AbstractIntervals) = mergesets((inx, iny) -> inx || iny, x, y)
Base.setdiff(x::AbstractIntervals, y::AbstractIntervals) = mergesets((inx, iny) -> inx && !iny, x, y)
Base.symdiff(x::AbstractIntervals, y::AbstractIntervals) = mergesets((inx, iny) -> inx ⊻ iny, x, y)
Base.issubset(x::AbstractIntervals, y::AbstractIntervals) = isempty(setdiff(x, y))
# may or may not be from Base (see top of `Intervals.jl`)
isdisjoint(x::AbstractIntervals, y::AbstractIntervals) = isempty(intersect(x, y))

Base.in(x, y::AbstractVector{<:AbstractInterval}) = any(yᵢ -> x ∈ yᵢ, y)
function Base.issetequal(x::AbstractIntervals, y::AbstractIntervals)
    x, y, tracking = unbunch(union(x), union(y))
    return x == y || (all(isempty, bunch(x, tracking)) && all(isempty, bunch(y, tracking)))
end
Base.length(x::AbstractInterval) = 1

# order edges so that closed boundaries are on the outside: e.g. [( )]
intersection_order(x::Endpoint) = isleft(x) ? !isclosed(x) : isclosed(x)
intersection_isless_fn(_::TrackStatically) = isless
intersection_isless_fn(::TrackEachEndpoint) = function(x,y)
    if isequal(x, y)
        return isless(intersection_order(x), intersection_order(y))
    else
        return isless(x, y)
    end
end

"""
    find_intersections(x::Union{AbstractInterval, AbstractVector{<:AbstractInterval}}, 
                       y::Union{AbstractInterval, AbstractVector{<:AbstractInterval}}; sorted=false)

Returns a Vector{Vector{Int}} where the value at index i gives the indices to
all intervals in `y` that intersect with `x[i]`.

"""
function find_intersections(x_::AbstractIntervals, y_::AbstractIntervals)
    xa = vcat(x_)
    tracking = endpoint_tracking(x_, y_)
    lt = intersection_isless_fn(tracking)
    x = unbunch(xa, tracking; enumerate=true, lt)
    y = unbunch(y_, tracking; enumerate=true, lt)
    result = [Vector{Int}() for _ in 1:length(xa)]

    find_intersections_helper(result, x, y, lt)
end
function find_intersections_helper(result, x, y, lt)
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
            x = Iterators.peel(x)[2]
        end

        if !x_less
            if isleft(yᵢ) && !x_less
                push!(active_ys, first(first(y)))
            else
                delete!(active_ys, first(first(y)))
            end
            y = Iterators.peel(y)[2]
        end

        for i in active_xs
            append!(result[i], active_ys)
        end
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
