struct Direction{T} end

const Lower = Direction{:Lower}()
const Upper = Direction{:Upper}()

const Beginning = Lower
const Ending = Upper

abstract type AbstractEndpoint end
struct Endpoint{T, D, B <: Bound} <: AbstractEndpoint
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

const LowerEndpoint{T,B} = Endpoint{T, Lower, B} where {T,B <: Bound}
const UpperEndpoint{T,B} = Endpoint{T, Upper, B} where {T,B <: Bound}

# the old names of lower and upper endpoint: they are not deprecated, because types cannot
# be deprecated (though their use is not discouraged)
const LeftEndpoint{T,B} = LowerEndpoint{T,B}
const RightEndpoint{T,B} = UpperEndpoint{T,B}

LowerEndpoint{B}(ep::T) where {T,B} = LowerEndpoint{T,B}(ep)
UpperEndpoint{B}(ep::T) where {T,B} = UpperEndpoint{T,B}(ep)

LowerEndpoint(i::AbstractInterval{T,L,U}) where {T,L,U} = LowerEndpoint{T,L}(L !== Unbounded ? lowerbound(i) : nothing)
UpperEndpoint(i::AbstractInterval{T,L,U}) where {T,L,U} = UpperEndpoint{T,U}(U !== Unbounded ? upperbound(i) : nothing)

endpoint(x::Endpoint) = isbounded(x) ? x.endpoint : nothing
bound_type(x::Endpoint{T,D,B}) where {T,D,B} = B

isclosed(x::Endpoint) = bound_type(x) === Closed
isunbounded(x::Endpoint) = bound_type(x) === Unbounded
isbounded(x::Endpoint) = bound_type(x) !== Unbounded

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

Base.broadcastable(e::Endpoint) = Ref(e)

"""
    ==(a::Endpoint, b::Endpoint) -> Bool

Determine if two endpoints are equal. When both endpoints are lower or upper then the points
and inclusiveness must be the same.

Checking the equality of lower-endpoint and a upper-endpoint is slightly more difficult. A
lower-endpoint and a upper-endpoint are only equal when they use the same point and are
both included. Note that lower/upper endpoints which are both not included are not equal
as the lower-endpoint contains values below that point while the upper-endpoint only contains
values that are above that point.

Visualizing two contiguous intervals can assist in understanding this logic:

    [x..y][y..z] -> UpperEndpoint == LowerEndpoint
    [x..y)[y..z] -> UpperEndpoint != LowerEndpoint
    [x..y](y..z] -> UpperEndpoint != LowerEndpoint
    [x..y)(y..z] -> UpperEndpoint != LowerEndpoint
"""
function Base.:(==)(a::Endpoint, b::Endpoint)
    return (
        isunbounded(a) && isunbounded(b) ||
        a.endpoint == b.endpoint && bound_type(a) == bound_type(b)
    )
end

function Base.:(==)(a::LowerEndpoint, b::UpperEndpoint)
    a.endpoint == b.endpoint && isclosed(a) && isclosed(b)
end

function Base.:(==)(a::UpperEndpoint, b::LowerEndpoint)
    b == a
end

function Base.isequal(a::Endpoint, b::Endpoint)
    return (
        isunbounded(a) && isunbounded(b) ||
        isequal(a.endpoint, b.endpoint) && isequal(bound_type(a), bound_type(b))
    )
end

function Base.isequal(a::LowerEndpoint, b::UpperEndpoint)
    isequal(a.endpoint, b.endpoint) && isclosed(a) && isclosed(b)
end

function Base.isequal(a::UpperEndpoint, b::LowerEndpoint)
    isequal(b, a)
end

function Base.isless(a::LowerEndpoint, b::LowerEndpoint)
    return (
        !isunbounded(b) && (
            isunbounded(a) ||
            a.endpoint < b.endpoint ||
            a.endpoint == b.endpoint && isclosed(a) && !isclosed(b)
        )
    )
end

function Base.isless(a::UpperEndpoint, b::UpperEndpoint)
    return (
        !isunbounded(a) && (
            isunbounded(b) ||
            a.endpoint < b.endpoint ||
            a.endpoint == b.endpoint && !isclosed(a) && isclosed(b)
        )
    )
end

function Base.isless(a::LowerEndpoint, b::UpperEndpoint)
    return (
        isunbounded(a) ||
        isunbounded(b) ||
        a.endpoint < b.endpoint
    )
end

function Base.isless(a::UpperEndpoint, b::LowerEndpoint)
    return (
        !isunbounded(a) && !isunbounded(b) &&
        (
            a.endpoint < b.endpoint ||
            a.endpoint == b.endpoint && !(isclosed(a) && isclosed(b))
        )
    )
end

# Comparisons between Scalars and Endpoints
Base.:(==)(a, b::Endpoint) = a == b.endpoint && isclosed(b)
Base.:(==)(a::Endpoint, b) = b == a

function Base.isless(a, b::LowerEndpoint)
    return (
        !isunbounded(b) && (
            a < b.endpoint ||
            a == b.endpoint && !isclosed(b)
        )
    )
end

function Base.isless(a::UpperEndpoint, b)
    return (
        !isunbounded(a) &&
        (
            a.endpoint < b ||
            a.endpoint == b && !isclosed(a)
        )
    )
end

Base.isless(a, b::UpperEndpoint) = isunbounded(b) || a < b.endpoint
Base.isless(a::LowerEndpoint, b)  = isunbounded(a) || a.endpoint < b
