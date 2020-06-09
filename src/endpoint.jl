struct Direction{T} end

const Left = Direction{:Left}()
const Right = Direction{:Right}()

const Beginning = Left
const Ending = Right

struct Endpoint{T,D,B}
    endpoint::T

    function Endpoint{T,D,B}(ep::T) where {T,D,B}
        @assert D isa Direction
        new{T,D,B}(ep)
    end
end

const LeftEndpoint{T,B} = Endpoint{T, Left, B} where {T,B}
const RightEndpoint{T,B} = Endpoint{T, Right, B} where {T,B}

LeftEndpoint{B}(ep::T) where {T,B} = LeftEndpoint{T,B}(ep)
RightEndpoint{B}(ep::T) where {T,B} = RightEndpoint{T,B}(ep)

LeftEndpoint(i::AbstractInterval{T,L,R}) where {T,L,R} = LeftEndpoint{T,L}(first(i))
RightEndpoint(i::AbstractInterval{T,L,R}) where {T,L,R} = RightEndpoint{T,R}(last(i))

bound(x::Endpoint{T,D,B}) where {T,D,B} = B
isclosed(x::Endpoint) = bound(x) === :closed

function Base.hash(x::Endpoint{T,D,B}, h::UInt) where {T,D,B}
    # Note: we shouldn't need to hash `T` as this is covered by the endpoint field.
    h = hash(:Endpoint, h)
    h = hash(D, h)
    h = hash(B, h)
    h = hash(x.endpoint, h)
    return h
end

Base.broadcastable(e::Endpoint) = Ref(e)

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
function Base.:(==)(a::Endpoint, b::Endpoint)
    a.endpoint == b.endpoint && isclosed(a) == isclosed(b)
end

function Base.:(==)(a::LeftEndpoint, b::RightEndpoint)
    a.endpoint == b.endpoint && isclosed(a) && isclosed(b)
end

function Base.:(==)(a::RightEndpoint, b::LeftEndpoint)
    b == a
end

function Base.isequal(a::Endpoint, b::Endpoint)
    isequal(a.endpoint, b.endpoint) && isequal(isclosed(a), isclosed(b))
end

function Base.isequal(a::LeftEndpoint, b::RightEndpoint)
    isequal(a.endpoint, b.endpoint) && isclosed(a) && isclosed(b)
end

function Base.isequal(a::RightEndpoint, b::LeftEndpoint)
    isequal(b, a)
end

function Base.isless(a::LeftEndpoint, b::LeftEndpoint)
    a.endpoint < b.endpoint || (a.endpoint == b.endpoint && isclosed(a) && !isclosed(b))
end

function Base.isless(a::RightEndpoint, b::RightEndpoint)
    a.endpoint < b.endpoint || (a.endpoint == b.endpoint && !isclosed(a) && isclosed(b))
end

function Base.isless(a::LeftEndpoint, b::RightEndpoint)
    a.endpoint < b.endpoint
end

function Base.isless(a::RightEndpoint, b::LeftEndpoint)
    a.endpoint < b.endpoint || (a.endpoint == b.endpoint && !(isclosed(a) && isclosed(b)))
end

# Comparisons between Scalars and Endpoints
Base.:(==)(a, b::Endpoint) = a == b.endpoint && isclosed(b)
Base.:(==)(a::Endpoint, b) = b == a

Base.isless(a, b::LeftEndpoint)  = a < b.endpoint || (a == b.endpoint && !isclosed(b))
Base.isless(a, b::RightEndpoint) = a < b.endpoint
Base.isless(a::LeftEndpoint, b)  = a.endpoint < b
Base.isless(a::RightEndpoint, b) = a.endpoint < b || (a.endpoint == b && !isclosed(a))
