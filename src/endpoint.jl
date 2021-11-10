struct Direction{T} end

const Left = Direction{:Left}()
const Right = Direction{:Right}()

const Beginning = Left
const Ending = Right

abstract type AbstractEndpoint{T}; end
struct Endpoint{T, D, B <: Bound} <: AbstractEndpoint{T}
    endpoint::T

    function Endpoint{T,D,B}(ep::T) where {T, D, B <: Bounded}
        @assert D isa Direction
        new{T,D,B}(ep)
    end

    function Endpoint{T,D,B}(ep::Nothing) where {T, D, B <: Unbounded}
        @assert D isa Direction
        new{T,D,B}()
    end

    function Endpoint{T,D,B}(ep::Nothing) where {T, D, B <: Bounded}
        throw(MethodError(Endpoint{T,D,B}, (ep,)))
    end
end

Endpoint{T,D,B}(ep) where {T, D, B <: Bounded} = Endpoint{T,D,B}(convert(T, ep))
Base.eltype(::AbstractEndpoint{T}) where T = T
Base.eltype(::Type{<:AbstractEndpoint{T}}) where T = T

# when all intervals are half-closed in the same direction (all [a, b) or all
# (b, a]) set operations over them are closed (e.g. all resulting intervals will
# be the same type). In these cases we can improve type invariance by using a
# `HalfOpenEndpoint`, which indicates whether the bounds are left-closed or
# right-closed, storing the left/right-ness as a flag
struct DirectionBound{T} end
const LeftClosed = DirectionBound{:LeftClosed}()
const RightClosed = DirectionBound{:RightClosed}()
struct HalfOpenEndpoint{T, B} <: AbstractEndpoint{T}
    endpoint::T
    left::Bool

    function HalfOpenEndpoint{T, B}(ep::T, left) where {T, B}
        @assert B isa DirectionBound
        new{T,B}(ep, left)
    end
end
HalfOpenEndpoint{T,B}(ep) where {T,B} = HalfOpenEndpoint{T,B}(convert(T, ep))

const LeftEndpoint{T,B} = Endpoint{T, Left, B} where {T,B <: Bound}
const RightEndpoint{T,B} = Endpoint{T, Right, B} where {T,B <: Bound}

LeftEndpoint{B}(ep::T) where {T,B} = LeftEndpoint{T,B}(ep)
RightEndpoint{B}(ep::T) where {T,B} = RightEndpoint{T,B}(ep)

LeftEndpoint(i::AbstractInterval{T,L,R}) where {T,L,R} = LeftEndpoint{T,L}(L !== Unbounded ? first(i) : nothing)
RightEndpoint(i::AbstractInterval{T,L,R}) where {T,L,R} = RightEndpoint{T,R}(R !== Unbounded ? last(i) : nothing)
LeftHalfOpenEndpoint(i::AbstractInterval{T, Closed, Open}) where T = HalfOpenEndpoint{T, LeftClosed}(first(i), true)
LeftHalfOpenEndpoint(i::AbstractInterval{T, Open, Closed}) where T = HalfOpenEndpoint{T, RightClosed}(first(i), true)
RightHalfOpenEndpoint(i::AbstractInterval{T, Closed, Open}) where T = HalfOpenEndpoint{T, LeftClosed}(last(i), false)
RightHalfOpenEndpoint(i::AbstractInterval{T, Open, Closed}) where T = HalfOpenEndpoint{T, RightClosed}(last(i), false)

endpoint(x::AbstractEndpoint) = isbounded(x) ? x.endpoint : nothing
bound_type(::Endpoint{T,D,B}) where {T,D,B} = B
bound_type(x::HalfOpenEndpoint{<:Any, LeftClosed}) = x.left ? Closed : Open
bound_type(x::HalfOpenEndpoint{<:Any, RightClosed}) = !x.left ? Closed : Open

isclosed(x::Endpoint) = bound_type(x) === Closed
isclosed(x::HalfOpenEndpoint) = bound_type(x) === Closed
isunbounded(x::Endpoint) = bound_type(x) === Unbounded
isbounded(x::Endpoint) = bound_type(x) !== Unbounded
isbounded(x::HalfOpenEndpoint) = true
isunbounded(x::HalfOpenEndpoint) = false

isleft(x::LeftEndpoint) = true
isleft(x::RightEndpoint) = false
isleft(x::HalfOpenEndpoint) = x.left

function Base.hash(x::Endpoint{T,D,B}, h::UInt) where {T,D,B}
    h = hash(:Endpoint, h)
    h = hash(D, h)
    h = hash(B, h)

    # Bounded endpoints can skip hashing `T` as this is handled by hashing the endpoint
    # value field. Unbounded endpoints however, should ignore the stored garbage value and
    # should hash `T`.`
    h = B !== Unbounded ? hash(x.endpoint, h) : hash(T, h)

    return h
end

function Base.hash(x::HalfOpenEndpoint{T,B}, h::UInt) where {T,B}
    h = hash(:HalfOpenEndpoint, h)
    h = hash(B, h)
    return hash(x.endpoint, h)
end

Base.broadcastable(e::Endpoint) = Ref(e)
Base.broadcastable(e::HalfOpenEndpoint) = Ref(e)

offset_value(x::Endpoint) = isleft(x) ? !isclosed(x) : isclosed(x)
"""
    ==(a::Endpoint, b::Endpoint) -> Bool

Determine if two endpoints are equal. When both endpoints are left or right then the points
and inclusiveness must be the same.

Checking the equality of left-endpoint and a right-endpoint is slightly more difficult. A
left-endpoint and a right-endpoint are only equal when they use the same point and are
both included. Note that left/right endpoints which are both not included are not equal
as the left-endpoint contains values below that point while the right-endpoint only contains
values that are above that point.

Visualizing two contiguous intervals can assist in understanding this logic:

    [x..y][y..z] -> RightEndpoint == LeftEndpoint
    [x..y)[y..z] -> RightEndpoint != LeftEndpoint
    [x..y](y..z] -> RightEndpoint != LeftEndpoint
    [x..y)(y..z] -> RightEndpoint != LeftEndpoint
"""
function Base.:(==)(a::AbstractEndpoint, b::AbstractEndpoint)
    return (
        isunbounded(a) && isunbounded(b) ||
        a.endpoint == b.endpoint && 
        (isleft(a) == isleft(b) ? isclosed(a) == isclosed(b) :
             isclosed(a) && isclosed(b))
    )
end

function Base.isequal(a::AbstractEndpoint, b::AbstractEndpoint)
    return (isunbounded(a) && isunbounded(b) ||
            isequal(a.endpoint, b.endpoint) &&
            (isleft(a) == isleft(b) ? isclosed(a) == isclosed(b) :
             isclosed(a) && isclosed(b)))
end

function Base.isless(a::AbstractEndpoint, b::AbstractEndpoint)
    if isleft(a) == isleft(b)
        return (
            !isunbounded(b) && (
                isunbounded(a) ||
                a.endpoint < b.endpoint ||
                a.endpoint == b.endpoint && 
                (offset_value(a) < offset_value(b))
            )
        )
    elseif isleft(a) && !isleft(b)
        return (
            isunbounded(a) ||
            isunbounded(b) ||
            a.endpoint < b.endpoint
        )
    else
        return (
            !isunbounded(a) && !isunbounded(b) &&
            (
                a.endpoint < b.endpoint ||
                a.endpoint == b.endpoint && !(isclosed(a) && isclosed(b))
            )
        )
    end
end

# Comparisons between Scalars and Endpoints
Base.:(==)(a::Number, b::Endpoint) = a == b.endpoint && isclosed(b)
Base.:(==)(a::Endpoint, b::Number) = b == a

function Base.isless(a::Number, b::AbstractEndpoint)
    if isleft(b)
        return (
            !isunbounded(b) && (
                a < b.endpoint ||
                a == b.endpoint && !isclosed(b)
            )
        )
    else
        return a < b.endpoint
    end
end

function Base.isless(a::AbstractEndpoint, b::Number)
    if !isleft(a)
        return (
            !isunbounded(a) &&
            (
                a.endpoint < b ||
                a.endpoint == b && !isclosed(a)
            )
        )
    else
        return a.endpoint < b
    end
end
